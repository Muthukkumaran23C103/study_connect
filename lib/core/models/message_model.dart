class Message {
  final int? id;
  final int groupId;
  final int senderId;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final DateTime timestamp;
  final bool isDeleted;

  // User info for display
  final String? senderName;
  final String? senderAvatar;

  Message({
    this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.attachmentUrl,
    required this.timestamp,
    this.isDeleted = false,
    this.senderName,
    this.senderAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'timestamp': timestamp.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id']?.toInt(),
      groupId: map['group_id']?.toInt() ?? 0,
      senderId: map['sender_id']?.toInt() ?? 0,
      content: map['content'] ?? '',
      messageType: map['message_type'] ?? 'text',
      attachmentUrl: map['attachment_url'],
      timestamp: DateTime.parse(map['timestamp']),
      isDeleted: map['is_deleted'] == 1,
      senderName: map['sender_name'],
      senderAvatar: map['sender_avatar'],
    );
  }

  Message copyWith({
    int? id,
    int? groupId,
    int? senderId,
    String? content,
    String? messageType,
    String? attachmentUrl,
    DateTime? timestamp,
    bool? isDeleted,
    String? senderName,
    String? senderAvatar,
  }) {
    return Message(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }
}
