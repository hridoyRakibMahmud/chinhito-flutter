class FeedPost {
  const FeedPost({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.body,
    required this.createdAt,
    this.destinationId,
    this.destinationName,
    this.destinationSlug,
    required this.likeCount,
  });

  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final DateTime createdAt;
  final String? destinationId;
  final String? destinationName;
  final String? destinationSlug;
  final int likeCount;

  factory FeedPost.fromMap(Map<String, dynamic> map) {
    final profile = map['user_profiles'] as Map<String, dynamic>?;
    final destination = map['destinations'] as Map<String, dynamic>?;
    final likeRows = map['post_likes'] as List<dynamic>?;
    final likeCount = (likeRows != null && likeRows.isNotEmpty)
        ? (likeRows.first['count'] as num?)?.toInt() ?? 0
        : 0;

    return FeedPost(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      authorName: (profile?['full_name'] as String?) ?? 'Traveler',
      authorAvatarUrl: profile?['avatar_url'] as String?,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      destinationId: map['destination_id'] as String?,
      destinationName: destination?['name'] as String?,
      destinationSlug: destination?['slug'] as String?,
      likeCount: likeCount,
    );
  }
}
