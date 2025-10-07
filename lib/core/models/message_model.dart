class Message {
  final int? id;
  final int groupId;
  final String senderId;
  final String senderName;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final DateTime timestamp;

  Message({
    this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.messageType = 'text',
    this.attachmentUrl,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      groupId: map['group_id'] ?? 0,
      senderId: map['sender_id'] ?? '',
      senderName: map['sender_name'] ?? '',
      content: map['content'] ?? '',
      messageType: map['message_type'] ?? 'text',
      attachmentUrl: map['attachment_url'],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
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
      'attachment_url': attachmentUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Message copyWith({
    int? id,
    int? groupId,
    String? senderId,
    String? senderName,
    String? content,
    String? messageType,
    String? attachmentUrl,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}