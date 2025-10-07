class Post {
  final int? id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final int? groupId;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.groupId,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['author_id'] ?? '',
      authorName: map['author_name'] ?? '',
      groupId: map['group_id'],
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'group_id': groupId,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    int? groupId,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      groupId: groupId ?? this.groupId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}