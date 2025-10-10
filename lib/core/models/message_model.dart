class MessageModel {
  final int? id;
  final int groupId;
  final String senderId;
  final String senderName;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final DateTime createdAt;

  MessageModel({
    this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as int?,
      groupId: map['group_id'] as int? ?? 0,
      senderId: map['sender_id'] as String? ?? '',
      senderName: map['sender_name'] as String? ?? '',
      content: map['content'] as String? ?? '',
      messageType: map['message_type'] as String? ?? 'text',
      mediaUrl: map['media_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'message_type': messageType,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    int? id,
    int? groupId,
    String? senderId,
    String? senderName,
    String? content,
    String? messageType,
    String? mediaUrl,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
