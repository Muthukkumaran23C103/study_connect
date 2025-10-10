import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<MessageModel> _messages = [];  // ← FIXED: Added proper type
  bool _isLoading = false;
  String? _errorMessage;

  List<MessageModel> get messages => _messages;  // ← FIXED: Added proper type
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMessages(int groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _databaseService.getMessagesForGroup(groupId);
    } catch (e) {
      _errorMessage = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      final messageId = await _databaseService.insertMessage(message);
      final newMessage = message.copyWith(id: messageId);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<MessageModel?> getLastMessage(int groupId) async {
    try {
      return await _databaseService.getLastMessage(groupId);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _databaseService.deleteMessage(messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
