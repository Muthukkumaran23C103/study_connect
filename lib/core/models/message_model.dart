class Message {
  final int? id;
  final int groupId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final String messageType;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;

  Message({
    this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.messageType = 'text',
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      groupId: map['group_id'] as int,
      senderId: map['sender_id'] as String,
      senderName: map['sender_name'] as String,
      senderAvatar: map['sender_avatar'] as String?,
      content: map['content'] as String,
      messageType: map['message_type'] as String? ?? 'text',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isRead: (map['is_read'] as int? ?? 0) == 1,
      attachmentUrl: map['attachment_url'] as String?,
      attachmentType: map['attachment_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'message_type': messageType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };
  }
}
