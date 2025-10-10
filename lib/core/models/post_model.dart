class PostModel {
  final int? id;
  final String content;
  final String authorId;
  final String authorName;
  final int? groupId;
  final List<String> mediaUrls;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PostModel({
    this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.groupId,
    this.mediaUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as int?,
      content: map['content'] as String? ?? '',
      authorId: map['author_id'] as String? ?? '',
      authorName: map['author_name'] as String? ?? '',
      groupId: map['group_id'] as int?,
      mediaUrls: map['media_urls'] != null
          ? (map['media_urls'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      likesCount: map['likes_count'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'group_id': groupId,
      'media_urls': mediaUrls.join(','),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PostModel copyWith({
    int? id,
    String? content,
    String? authorId,
    String? authorName,
    int? groupId,
    List<String>? mediaUrls,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      groupId: groupId ?? this.groupId,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
