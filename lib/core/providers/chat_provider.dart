import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMessagesForGroup(int groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _messages = await _databaseService.getMessagesForGroup(groupId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Message?> getLastMessage(int groupId) async {
    try {
      return await _databaseService.getLastMessage(groupId);
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage({
    required int groupId,
    required String senderId,
    required String senderName,
    required String content,
    String? attachmentUrl,
  }) async {
    try {
      final message = Message(
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        attachmentUrl: attachmentUrl,
        timestamp: DateTime.now(),
      );

      final messageId = await _databaseService.insertMessage(message);

      // Add to local list immediately for better UX
      _messages.add(message.copyWith(id: messageId));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}