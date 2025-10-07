import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ChatProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages(int groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _databaseService.getMessagesForGroup(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Message?> getLastMessage(int groupId) async {
    try {
      return await _databaseService.getLastMessage(groupId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required int groupId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? senderAvatar,
  }) async {
    try {
      final message = Message(
        senderId: senderId,
        senderName: senderName,
        groupId: groupId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        senderAvatar: senderAvatar,
        timestamp: DateTime.now().toIso8601String(),
      );

      final messageId = await _databaseService.insertMessage(message);

      final newMessage = message.copyWith(id: messageId);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}