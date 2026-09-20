import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/destination.dart';
import '../../../shared/providers/destinations_provider.dart';
import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../../feed/data/feed_repository.dart';
import '../../visited_tracking/data/visited_places_repository.dart';

/// Total district count nationwide — matches the 64 districts seeded from
/// the bundled Bangladesh boundary data (see supabase/seed_divisions_districts.sql).
const _kTotalDistricts = 64;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return Scaffold(
      body: SafeArea(
        child: isSignedIn ? const _LoggedInProfile() : const _LoggedOutProfile(),
      ),
    );
  }
}

class _LoggedInProfile extends ConsumerWidget {
  const _LoggedInProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final destinationsAsync = ref.watch(publishedDestinationsProvider);
    final visitedIdsAsync = ref.watch(visitedDestinationIdsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.teal,
                backgroundImage: user?.userMetadata?['avatar_url'] != null
                    ? NetworkImage(user!.userMetadata!['avatar_url'] as String)
                    : null,
                child: user?.userMetadata?['avatar_url'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.userMetadata?['full_name'] as String? ?? user?.email ?? 'Signed in',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                    Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF8a8a8a))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _StatsRow(destinationsAsync: destinationsAsync, visitedIdsAsync: visitedIdsAsync),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _MyPostsCard(user: user),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.terracotta, width: 1.5),
                foregroundColor: AppColors.terracotta,
              ),
              child: const Text('Sign out'),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.destinationsAsync, required this.visitedIdsAsync});

  final AsyncValue<List<Destination>> destinationsAsync;
  final AsyncValue<Set<String>> visitedIdsAsync;

  @override
  Widget build(BuildContext context) {
    final destinations = destinationsAsync.value;
    final visitedIds = visitedIdsAsync.value;

    int visitedCount = 0;
    int districtsStarted = 0;
    if (destinations != null && visitedIds != null) {
      final visited = destinations.where((d) => visitedIds.contains(d.id));
      visitedCount = visited.length;
      districtsStarted = visited.map((d) => d.districtId).toSet().length;
    }
    final countryPct = (districtsStarted / _kTotalDistricts * 100).round();

    return Row(
      children: [
        Expanded(child: _StatCard(value: '$visitedCount', label: 'Places visited', color: AppColors.teal)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(value: '$districtsStarted', label: 'Districts started', color: AppColors.terracotta)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(value: '$countryPct%', label: 'of country', color: AppColors.mustard)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF8a8a8a))),
          ],
        ),
      ),
    );
  }
}

class _MyPostsCard extends ConsumerWidget {
  const _MyPostsCard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(feedPostsProvider);
    final myPostsCount = postsAsync.value?.where((p) => p.userId == user?.id).length ?? 0;
    final summary = myPostsCount > 0
        ? "You've shared $myPostsCount post${myPostsCount > 1 ? 's' : ''}."
        : "You haven't posted yet — share your first experience from the Community tab.";

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            const Text('My posts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summary,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8a8a8a)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedOutProfile extends StatelessWidget {
  const _LoggedOutProfile();

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
            const Text("You're not signed in", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 8),
            const Text(
              'Sign in to track visited places and see your stats. Browsing never requires an account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF8a8a8a), height: 1.5),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/sign-in', extra: 'Sign in to track your visited places and see your travel stats.'),
                child: const Text('Sign in with Google'),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => context.go('/'),
              child: const Text('Keep exploring', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6b6b6b))),
            ),
          ],
        ),
      ),
    );
  }
}
