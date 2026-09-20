import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/destination.dart';
import '../../../shared/providers/destinations_provider.dart';
import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/destination_card.dart';
import '../../visited_tracking/application/visited_tracking_controller.dart';
import '../../visited_tracking/data/visited_places_repository.dart';

class DestinationDetailScreen extends ConsumerWidget {
  const DestinationDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinationsAsync = ref.watch(publishedDestinationsProvider);
    final visitedIdsAsync = ref.watch(visitedDestinationIdsProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: destinationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Failed to load: $error')),
          data: (destinations) {
            Destination? found;
            for (final d in destinations) {
              if (d.slug == slug) {
                found = d;
                break;
              }
            }
            if (found == null) {
              return const Center(child: Text('Destination not found'));
            }
            final destination = found;
            final total = destinations.where((d) => d.districtId == destination.districtId).length;
            final visitedIds = visitedIdsAsync.value ?? const <String>{};
            final visitedInDistrict = destinations
                .where((d) => d.districtId == destination.districtId && visitedIds.contains(d.id))
                .length;
            final pct = total == 0 ? 0 : ((visitedInDistrict / total) * 100).round();
            final isVisited = visitedIds.contains(destination.id);

            return _DetailBody(
              destination: destination,
              isVisited: isVisited,
              districtPct: pct,
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.destination, required this.isVisited, required this.districtPct});

  final Destination destination;
  final bool isVisited;
  final int districtPct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggling = ref.watch(visitedTrackingControllerProvider).isLoading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 230,
                color: AppColors.teal.withValues(alpha: 0.12),
                child: Icon(categoryIcon(destination.category), size: 56, color: AppColors.teal),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: _RoundIconButton(icon: Icons.arrow_back, onPressed: () => context.pop()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EEED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    destination.category.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal),
                  ),
                ),
                const SizedBox(height: 10),
                Text(destination.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${destination.districtName}, ${destination.divisionName} · ★ ${destination.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
                ),
                if (destination.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    destination.description!,
                    style: const TextStyle(fontSize: 16, color: AppColors.charcoal, height: 1.55),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: isVisited
                      ? FilledButton.tonal(
                          onPressed: toggling ? null : () => _handleToggleVisit(context, ref),
                          child: toggling ? const _ButtonSpinner() : const Text('✓ Visited'),
                        )
                      : FilledButton(
                          onPressed: toggling ? null : () => _handleToggleVisit(context, ref),
                          child: toggling ? const _ButtonSpinner() : const Text('Mark as visited'),
                        ),
                ),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${destination.districtName} progress',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                            ),
                            Text('$districtPct%', style: const TextStyle(fontSize: 14, color: Color(0xFF6b6b6b))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: districtPct / 100, minHeight: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('From the community', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                const Text(
                  'No community posts about this place yet.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9a9a9a)),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => context.go('/feed'),
                  child: const Text(
                    'See all posts about this place →',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleVisit(BuildContext context, WidgetRef ref) async {
    final isSignedIn = ref.read(isSignedInProvider);
    if (!isSignedIn) {
      context.push(
        '/sign-in',
        extra: 'Sign in to mark places as visited and track your progress across Bangladesh.',
      );
      return;
    }
    await ref
        .read(visitedTrackingControllerProvider.notifier)
        .toggleVisited(destination.id, currentlyVisited: isVisited);
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.charcoal),
        ),
      ),
    );
  }
}
