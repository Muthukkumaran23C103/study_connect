import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages(int groupId) async {
    _setLoading(true);
    try {
      _messages = await _databaseService.getMessagesForGroup(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  List<Message> getMessagesForGroup(int groupId) {
    return _messages.where((message) => message.groupId == groupId).toList();
  }

  Future<Message?> getLastMessage(int groupId) async {
    try {
      return await _databaseService.getLastMessage(groupId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<void> sendMessage({
    required String content,
    required String senderId,
    required String senderName,
    required int groupId,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    try {
      final message = Message(
        content: content,
        senderId: senderId,
        senderName: senderName,
        groupId: groupId,
        messageType: messageType,
        createdAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      );

      final messageId = await _databaseService.insertMessage(message);

      // Add to local list with the generated ID
      _messages.add(Message(
        id: messageId,
        content: content,
        senderId: senderId,
        senderName: senderName,
        groupId: groupId,
        messageType: messageType,
        createdAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      ));

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
