import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/message_model.dart';
import '../../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  int? _currentGroupId;

  // Typing indicator
  Map<int, bool> _typingUsers = {};
  Timer? _typingTimer;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int? get currentGroupId => _currentGroupId;

  bool isUserTyping(int userId) => _typingUsers[userId] ?? false;

  // Load messages for a specific group
  Future<void> loadMessages(int groupId) async {
    if (_currentGroupId == groupId && _messages.isNotEmpty) {
      return; // Already loaded
    }

    _isLoading = true;
    _error = null;
    _currentGroupId = groupId;
    notifyListeners();

    try {
      _messages = await _databaseService.getMessages(groupId);
      _messages = _messages.reversed.toList(); // Reverse for chronological order
    } catch (e) {
      _error = 'Failed to load messages: $e';
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage({
    required int groupId,
    required int senderId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    if (content.trim().isEmpty && messageType == 'text') return;

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final message = Message(
        groupId: groupId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        timestamp: DateTime.now(),
      );

      final messageId = await _databaseService.insertMessage(message);

      // Add to local list immediately for better UX
      final newMessage = message.copyWith(id: messageId);
      _messages.add(newMessage);

      // Stop typing indicator
      _typingUsers[senderId] = false;

    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // Delete a message
  Future<void> deleteMessage(int messageId) async {
    try {
      await _databaseService.deleteMessage(messageId);
      _messages.removeWhere((message) => message.id == messageId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  // Typing indicator
  void setTyping(int userId, bool isTyping) {
    _typingUsers[userId] = isTyping;
    notifyListeners();

    if (isTyping) {
      // Auto-stop typing after 3 seconds
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _typingUsers[userId] = false;
        notifyListeners();
      });
    }
  }

  // Refresh messages (for pull-to-refresh)
  Future<void> refreshMessages() async {
    if (_currentGroupId != null) {
      _messages.clear();
      await loadMessages(_currentGroupId!);
    }
  }

  // Clear chat data
  void clearChat() {
    _messages.clear();
    _currentGroupId = null;
    _typingUsers.clear();
    _typingTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
