import 'dart:convert';

class Post {
  final int? id;
  final int groupId;
  final int authorId;
  final String? title;
  final String content;
  final String postType;
  final List<String> attachmentUrls;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  // User info for display
  final String? authorName;
  final String? authorAvatar;
  final String? groupName;

  Post({
    this.id,
    required this.groupId,
    required this.authorId,
    this.title,
    required this.content,
    this.postType = 'general',
    this.attachmentUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.groupName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'author_id': authorId,
      'title': title,
      'content': content,
      'post_type': postType,
      'attachment_urls': json.encode(attachmentUrls),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id']?.toInt(),
      groupId: map['group_id']?.toInt() ?? 0,
      authorId: map['author_id']?.toInt() ?? 0,
      title: map['title'],
      content: map['content'] ?? '',
      postType: map['post_type'] ?? 'general',
      attachmentUrls: map['attachment_urls'] != null
          ? List<String>.from(json.decode(map['attachment_urls']))
          : [],
      likesCount: map['likes_count']?.toInt() ?? 0,
      commentsCount: map['comments_count']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      authorName: map['author_name'],
      authorAvatar: map['author_avatar'],
      groupName: map['group_name'],
    );
  }

  Post copyWith({
    int? id,
    int? groupId,
    int? authorId,
    String? title,
    String? content,
    String? postType,
    List<String>? attachmentUrls,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    String? authorName,
    String? authorAvatar,
    String? groupName,
  }) {
    return Post(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      groupName: groupName ?? this.groupName,
    );
  }
}
