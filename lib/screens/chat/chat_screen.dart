import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/providers/chat_provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/message_model.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';

class ChatScreen extends StatefulWidget {
  final int groupId;

  const ChatScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages(widget.groupId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = context.read<StudyGroupProvider>().getGroupById(widget.groupId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group?.name ?? 'Group Chat'),
            if (group != null)
              Text(
                '${group.memberCount} members',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGroupInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getMessagesForGroup(widget.groupId);

                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${chatProvider.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () => chatProvider.loadMessages(widget.groupId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final currentUserId = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
                    final isOwnMessage = message.senderId == currentUserId;

                    bool showDateSeparator = false;
                    if (index == 0) {
                      showDateSeparator = true;
                    } else {
                      final previousMessage = messages[index - 1];
                      final currentDate = DateTime(
                        message.timestamp.year,
                        message.timestamp.month,
                        message.timestamp.day,
                      );
                      final previousDate = DateTime(
                        previousMessage.timestamp.year,
                        previousMessage.timestamp.month,
                        previousMessage.timestamp.day,
                      );
                      showDateSeparator = !currentDate.isAtSameMomentAs(previousDate);
                    }

                    return Column(
                      children: [
                        if (showDateSeparator)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDate(message.timestamp),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        MessageBubble(
                          message: message,
                          isOwnMessage: isOwnMessage,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSendMessage: _sendMessage,
            onSendAttachment: _sendAttachment,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      await chatProvider.sendMessage(
        groupId: widget.groupId,
        senderId: currentUser.id.toString(),
        senderName: currentUser.displayName,
        content: content.trim(),
        messageType: 'text',
      );

      // Auto-scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _sendAttachment() async {
    // Implement attachment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attachment feature coming soon!')),
    );
  }

  void _showGroupInfo(BuildContext context) {
    final group = context.read<StudyGroupProvider>().getGroupById(widget.groupId);

    if (group == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 8),
                Text('${group.memberCount} members'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 8),
                Text(group.category),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16),
                const SizedBox(width: 8),
                Text('Created: ${DateFormat('MMM dd, yyyy').format(group.createdAt)}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
