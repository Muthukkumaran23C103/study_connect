class Post {
  final int? id;
  final String content;
  final String authorId;
  final String authorName;
  final int? groupId;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String? attachmentUrl;

  Post({
    this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.groupId,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'group_id': groupId,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    String? content,
    String? authorId,
    String? authorName,
    int? groupId,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    String? attachmentUrl,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      groupId: groupId ?? this.groupId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
