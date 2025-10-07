class Post {
  final int? id;
  final String authorId;
  final int? groupId;
  final String title;
  final String? content;
  final String? attachmentUrls;
  final int likesCount;
  final int commentsCount;
  final String createdAt;
  final String? updatedAt;

  Post({
    this.id,
    required this.authorId,
    this.groupId,
    required this.title,
    this.content,
    this.attachmentUrls,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'groupId': groupId,
      'title': title,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id']?.toInt(),
      authorId: map['authorId'] ?? '',
      groupId: map['groupId']?.toInt(),
      title: map['title'] ?? '',
      content: map['content'],
      attachmentUrls: map['attachmentUrls'],
      likesCount: map['likesCount']?.toInt() ?? 0,
      commentsCount: map['commentsCount']?.toInt() ?? 0,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'],
    );
  }

  Post copyWith({
    int? id,
    String? authorId,
    int? groupId,
    String? title,
    String? content,
    String? attachmentUrls,
    int? likesCount,
    int? commentsCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      content: content ?? this.content,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}