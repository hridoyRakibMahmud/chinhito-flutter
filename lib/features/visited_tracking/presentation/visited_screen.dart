import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/destinations_provider.dart';
import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/destination_card.dart';
import '../data/visited_places_repository.dart';

class VisitedScreen extends ConsumerWidget {
  const VisitedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Visited', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                "Places you've marked as visited",
                style: TextStyle(fontSize: 14, color: Color(0xFF8a8a8a)),
              ),
            ),
            Expanded(
              child: !isSignedIn
                  ? _LoggedOut(onSignIn: () => context.push('/sign-in', extra: 'Sign in to see your visited places.'))
                  : _VisitedList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinationsAsync = ref.watch(publishedDestinationsProvider);
    final visitedIdsAsync = ref.watch(visitedDestinationIdsProvider);

    if (destinationsAsync.isLoading || visitedIdsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (destinationsAsync.hasError) {
      return Center(child: Text('Failed to load: ${destinationsAsync.error}'));
    }
    if (visitedIdsAsync.hasError) {
      return Center(child: Text('Failed to load: ${visitedIdsAsync.error}'));
    }

    final visitedIds = visitedIdsAsync.value!;
    final visited = destinationsAsync.value!.where((d) => visitedIds.contains(d.id)).toList();

    if (visited.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No places marked as visited yet. Open a destination and tap "Mark as visited" to start your list.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF8a8a8a), height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: () => context.go('/'),
                child: const Text('Explore the map'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: visited.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final destination = visited[index];
        return DestinationCard(
          destination: destination,
          onTap: () => context.push('/destinations/${destination.slug}'),
        );
      },
    );
  }
}

class _LoggedOut extends StatelessWidget {
  const _LoggedOut({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFEFE9DD), shape: BoxShape.circle),
              child: const Icon(Icons.question_mark, color: Color(0xFF8a8a8a)),
            ),
            const SizedBox(height: 20),
            const Text("You're not signed in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 8),
            const Text(
              'Sign in to start marking places as visited.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF8a8a8a), height: 1.5),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onSignIn, child: const Text('Sign in with Google')),
            ),
          ],
        ),
      ),
    );
  }
}
