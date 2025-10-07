import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/models/message_model.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';

class ChatScreen extends StatefulWidget {
  final StudyGroup group;

  const ChatScreen({
    super.key,
    required this.group,
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
      context.read<ChatProvider>().loadMessages(widget.group.id!);
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

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      _messageController.clear();

      await chatProvider.sendMessage(
        senderId: currentUser.id.toString(),
        senderName: currentUser.displayName,
        groupId: widget.group.id!,
        content: message,
      );

      _scrollToBottom();
    }
  }

  void _sendAttachment() async {
    // TODO: Implement file picker and attachment sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attachment feature coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.group.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
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
          Expanded(
            child: Consumer2<ChatProvider, AuthProvider>(
              builder: (context, chatProvider, authProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${chatProvider.error}'),
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
                final currentUser = authProvider.currentUser;

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
                    final isOwnMessage = currentUser != null &&
                        message.senderId == currentUser.id.toString();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MessageBubble(
                        message: message,
                        isOwn: isOwnMessage,
                      ),
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
}