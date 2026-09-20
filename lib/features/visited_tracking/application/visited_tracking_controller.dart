import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../data/visited_places_repository.dart';

part 'visited_tracking_controller.g.dart';

@riverpod
class VisitedTrackingController extends _$VisitedTrackingController {
  @override
  FutureOr<void> build() {}

  /// Caller must already have gated this on the user being signed in.
  Future<void> toggleVisited(String destinationId, {required bool currentlyVisited}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(visitedPlacesRepositoryProvider);
      if (currentlyVisited) {
        await repo.unmarkVisited(user.id, destinationId);
      } else {
        await repo.markVisited(user.id, destinationId);
      }
      ref.invalidate(visitedDestinationIdsProvider);
    });
  }
}
