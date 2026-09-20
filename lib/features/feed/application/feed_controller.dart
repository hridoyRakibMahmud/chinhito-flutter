import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../data/feed_repository.dart';

part 'feed_controller.g.dart';

@riverpod
class FeedController extends _$FeedController {
  @override
  FutureOr<void> build() {}

  /// Caller must already have gated this on the user being signed in.
  Future<void> createPost({required String body, String? destinationId}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedRepositoryProvider).createPost(
            userId: user.id,
            body: body,
            destinationId: destinationId,
          );
      ref.invalidate(feedPostsProvider);
    });
  }

  Future<void> toggleLike(String postId, {required bool currentlyLiked}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedRepositoryProvider);
      if (currentlyLiked) {
        await repo.unlike(user.id, postId);
      } else {
        await repo.like(user.id, postId);
      }
      ref.invalidate(likedPostIdsProvider);
      ref.invalidate(feedPostsProvider);
    });
  }
}
