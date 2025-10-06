class Post {
  final int? id;
  final int groupId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String content;
  final String postType;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String? attachmentUrl;
  final String? attachmentType;

  Post({
    this.id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    required this.content,
    this.postType = 'text',
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      groupId: map['group_id'] as int,
      authorId: map['author_id'] as String,
      authorName: map['author_name'] as String,
      authorAvatar: map['author_avatar'] as String?,
      title: map['title'] as String,
      content: map['content'] as String,
      postType: map['post_type'] as String? ?? 'text',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      likeCount: map['like_count'] as int? ?? 0,
      commentCount: map['comment_count'] as int? ?? 0,
      isLiked: (map['is_liked'] as int? ?? 0) == 1,
      attachmentUrl: map['attachment_url'] as String?,
      attachmentType: map['attachment_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'title': title,
      'content': content,
      'post_type': postType,
      'created_at': createdAt.millisecondsSinceEpoch,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked ? 1 : 0,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };
  }
}
