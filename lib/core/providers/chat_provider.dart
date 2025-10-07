import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadMessages(int groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _databaseService.getMessagesForGroup(groupId);
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Message?> getLastMessage(int groupId) async {
    try {
      return await _databaseService.getLastMessage(groupId);
    } catch (e) {
      print('Error getting last message: $e');
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

      final newMessage = message.copyWith(id: messageId);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}