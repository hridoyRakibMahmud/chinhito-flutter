import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/feed_post.dart';
import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/time_ago.dart';
import '../application/feed_controller.dart';
import '../data/feed_repository.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);
    final postsAsync = ref.watch(feedPostsProvider);
    final likedIds = ref.watch(likedPostIdsProvider).value ?? const <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.teal),
            onPressed: () => _openCompose(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Text-only stories from travelers across Bangladesh',
                style: TextStyle(fontSize: 14, color: Color(0xFF8a8a8a)),
              ),
            ),
          ),
          if (!isSignedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _LoginBanner(onSignIn: () => _openCompose(context, ref)),
            ),
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Failed to load: $error')),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No posts yet — be the first to share.', style: TextStyle(color: Color(0xFF9a9a9a))),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _PostCard(post: post, liked: likedIds.contains(post.id));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openCompose(BuildContext context, WidgetRef ref) {
    if (ref.read(isSignedInProvider)) {
      context.push('/compose');
    } else {
      context.push('/sign-in', extra: 'Sign in to share your experience with the community.');
    }
  }
}

class _LoginBanner extends StatelessWidget {
  const _LoginBanner({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFFBEFE4), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Expanded(
            child: Text('Sign in to share your own experiences', style: TextStyle(fontSize: 14, color: AppColors.charcoal)),
          ),
          InkWell(
            onTap: onSignIn,
            child: const Text(
              'Sign in',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.terracotta),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post, required this.liked});

  final FeedPost post;
  final bool liked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching (not just reading) keeps this controller alive for the whole
    // async like/unlike round trip — otherwise, with nothing watching it,
    // Riverpod disposes the autoDispose provider almost immediately after
    // the fire-and-forget `.read(...).toggleLike(...)` call returns, and the
    // `ref.invalidate(...)` calls it makes after the network await run on an
    // already-disposed ref and silently no-op (the write itself still
    // succeeds, which is why a full reload showed the correct state).
    final liking = ref.watch(feedControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.teal,
                backgroundImage: post.authorAvatarUrl != null ? NetworkImage(post.authorAvatarUrl!) : null,
                child: post.authorAvatarUrl == null
                    ? Text(
                        post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  Text(timeAgo(post.createdAt), style: const TextStyle(fontSize: 12, color: Color(0xFFa3a3a3))),
                ],
              ),
            ],
          ),
          if (post.destinationSlug != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => context.push('/destinations/${post.destinationSlug}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFE4EEED), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '📍 ${post.destinationName}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(post.body, style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.55)),
          const SizedBox(height: 12),
          InkWell(
            onTap: liking ? null : () => _handleLike(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (liking)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(liked ? Icons.favorite : Icons.favorite_border, size: 16, color: liked ? AppColors.terracotta : const Color(0xFF8a8a8a)),
                  const SizedBox(width: 6),
                  Text('${post.likeCount}', style: const TextStyle(fontSize: 13, color: Color(0xFF8a8a8a))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike(BuildContext context, WidgetRef ref) {
    if (!ref.read(isSignedInProvider)) {
      context.push('/sign-in', extra: 'Sign in to like posts from the community.');
      return;
    }
    ref.read(feedControllerProvider.notifier).toggleLike(post.id, currentlyLiked: liked);
  }
}
