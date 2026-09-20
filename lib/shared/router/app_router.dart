import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/destination_detail/presentation/destination_detail_screen.dart';
import '../../features/map_explore/presentation/map_explore_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../providers/supabase_provider.dart';

part 'app_router.g.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final refreshStream = GoRouterRefreshStream(client.auth.onAuthStateChange);
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final signedIn = client.auth.currentUser != null;
      final goingToSignIn = state.matchedLocation == '/sign-in';

      // Browsing the map/details never requires login; only /profile does.
      if (state.matchedLocation == '/profile' && !signedIn) return '/sign-in';
      if (goingToSignIn && signedIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MapExploreScreen()),
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(
        path: '/destinations/:slug',
        builder: (context, state) =>
            DestinationDetailScreen(slug: state.pathParameters['slug']!),
      ),
    ],
  );
}
