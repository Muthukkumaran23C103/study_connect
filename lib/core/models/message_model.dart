class Message {
  final int? id;
  final String content;
  final String senderId;
  final String senderName;
  final int groupId;
  final String messageType;
  final DateTime createdAt;
  final String? attachmentUrl;

  Message({
    this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.groupId,
    this.messageType = 'text',
    required this.createdAt,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'group_id': groupId,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
