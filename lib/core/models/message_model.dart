class Message {
  final int? id;
  final String senderId;
  final String senderName;
  final int groupId;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final String? senderAvatar;
  final String timestamp;

  Message({
    this.id,
    required this.senderId,
    required this.senderName,
    required this.groupId,
    required this.content,
    this.messageType = 'text',
    this.attachmentUrl,
    this.senderAvatar,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'groupId': groupId,
      'content': content,
      'messageType': messageType,
      'attachmentUrl': attachmentUrl,
      'senderAvatar': senderAvatar,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id']?.toInt(),
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      groupId: map['groupId']?.toInt() ?? 0,
      content: map['content'] ?? '',
      messageType: map['messageType'] ?? 'text',
      attachmentUrl: map['attachmentUrl'],
      senderAvatar: map['senderAvatar'],
      timestamp: map['timestamp'] ?? '',
    );
  }

  Message copyWith({
    int? id,
    String? senderId,
    String? senderName,
    int? groupId,
    String? content,
    String? messageType,
    String? attachmentUrl,
    String? senderAvatar,
    String? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}