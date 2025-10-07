import 'package:flutter/foundation.dart';
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
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> sendMessage({
    required int groupId,
    required String senderId,
    required String senderName,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    try {
      final message = Message(
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        timestamp: DateTime.now(),
      );

      final messageId = await _databaseService.insertMessage(message);

      // Add the new message to the local list
      final newMessage = message.copyWith(id: messageId);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}