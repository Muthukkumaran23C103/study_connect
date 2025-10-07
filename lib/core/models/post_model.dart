class Post {
  final int? id;
  final String authorId;
  final String authorName;
  final int? groupId;
  final String title;
  final String content;
  final String? attachmentUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    this.id,
    required this.authorId,
    required this.authorName,
    this.groupId,
    required this.title,
    required this.content,
    this.attachmentUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'groupId': groupId,
      'title': title,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id']?.toInt(),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      groupId: map['groupId']?.toInt(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      attachmentUrl: map['attachmentUrl'],
      likesCount: map['likesCount']?.toInt() ?? 0,
      commentsCount: map['commentsCount']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Post copyWith({
    int? id,
    String? authorId,
    String? authorName,
    int? groupId,
    String? title,
    String? content,
    String? attachmentUrl,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}