import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/destination_detail/presentation/destination_detail_screen.dart';
import '../../features/feed/presentation/compose_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/map_explore/presentation/map_explore_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/visited_tracking/presentation/visited_screen.dart';
import '../providers/supabase_provider.dart';
import 'scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshStream,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const MapExploreScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/feed', builder: (context, state) => const FeedScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/visited', builder: (context, state) => const VisitedScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      // Pushed above the shell (root navigator) so they render full-screen,
      // without the bottom nav — matches the design's push/modal screens.
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SignInScreen(reason: state.extra as String?),
      ),
      GoRoute(
        path: '/destinations/:slug',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            DestinationDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/compose',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ComposeScreen(),
      ),
    ],
  );
}
