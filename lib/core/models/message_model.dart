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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'messageType': messageType,
      'attachmentUrl': attachmentUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id']?.toInt(),
      groupId: map['groupId']?.toInt() ?? 0,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      messageType: map['messageType'] ?? 'text',
      attachmentUrl: map['attachmentUrl'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
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