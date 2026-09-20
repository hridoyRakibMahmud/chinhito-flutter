import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/feed_post.dart';
import '../../../shared/providers/supabase_provider.dart';

part 'feed_repository.g.dart';

class FeedRepository {
  FeedRepository(this._client);

  final SupabaseClient _client;

  Future<List<FeedPost>> fetchPosts() async {
    final rows = await _client
        .from('feed_posts')
        .select('*, user_profiles(full_name, avatar_url), destinations(name, slug), post_likes(count)')
        .order('created_at', ascending: false);
    return rows.map(FeedPost.fromMap).toList();
  }

  Future<void> createPost({required String userId, required String body, String? destinationId}) {
    return _client.from('feed_posts').insert({
      'user_id': userId,
      'body': body,
      'destination_id': ?destinationId,
    });
  }

  Future<Set<String>> fetchLikedPostIds(String userId) async {
    final rows = await _client.from('post_likes').select('post_id').eq('user_id', userId);
    return rows.map((row) => row['post_id'] as String).toSet();
  }

  Future<void> like(String userId, String postId) {
    return _client.from('post_likes').insert({'user_id': userId, 'post_id': postId});
  }

  Future<void> unlike(String userId, String postId) {
    return _client.from('post_likes').delete().eq('user_id', userId).eq('post_id', postId);
  }
}

@riverpod
FeedRepository feedRepository(Ref ref) {
  return FeedRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<FeedPost>> feedPosts(Ref ref) {
  return ref.watch(feedRepositoryProvider).fetchPosts();
}

@riverpod
Future<Set<String>> likedPostIds(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const {};
  return ref.watch(feedRepositoryProvider).fetchLikedPostIds(user.id);
}
