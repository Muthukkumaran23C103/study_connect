import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/study_group_model.dart';
import '../../core/models/message_model.dart';
import '../../core/models/user_model.dart';  // ← ADD THIS IMPORT
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';

class ChatScreen extends StatefulWidget {
  final StudyGroupModel group;

  const ChatScreen({
    super.key,
    required this.group,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages(widget.group.id!);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              '${widget.group.memberCount} members',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show group info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (chatProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${chatProvider.errorMessage}'),
                        ElevatedButton(
                          onPressed: () {
                            chatProvider.loadMessages(widget.group.id!);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final messages = chatProvider.messages;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final currentUser = context.read<AuthProvider>().currentUser;
                    final isOwn = message.senderId == currentUser?.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MessageBubble(
                        message: message,
                        isOwn: isOwn,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final currentUser = authProvider.currentUser;
                if (currentUser == null) {
                  return const Text('Please log in to send messages');
                }

                return MessageInput(
                  textController: _messageController,
                  onSendMessage: () => _sendMessage(currentUser),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(UserModel currentUser) async {
    if (_messageController.text.trim().isEmpty) return;

    final message = MessageModel(
      groupId: widget.group.id!,
      senderId: currentUser.id,
      senderName: currentUser.displayName,
      content: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    await context.read<ChatProvider>().sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendAttachment(String senderId, String senderName) {
    // TODO: Implement attachment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attachment functionality coming soon!')),
    );
  }
}
