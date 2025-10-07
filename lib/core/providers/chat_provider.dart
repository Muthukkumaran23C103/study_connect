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

  Future<void> loadMessages(int groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _databaseService.getMessagesForGroup(groupId);
    } catch (e) {
      _errorMessage = e.toString();
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
    String? attachmentPath,
    String? attachmentType,
  }) async {
    try {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch,
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        timestamp: DateTime.now(),
        attachmentPath: attachmentPath,
        attachmentType: attachmentType,
      );

      final messageId = await _databaseService.insertMessage(message);

      final newMessage = message.copyWith(id: messageId);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
