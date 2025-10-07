import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/study_group_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';

class ChatScreen extends StatefulWidget {
  final StudyGroup group;

  const ChatScreen({Key? key, required this.group}) : super(key: key);

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
      context.read<ChatProvider>().loadMessagesForGroup(widget.group.id!);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.group.name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.group.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Group info screen
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: \${chatProvider.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            chatProvider.loadMessagesForGroup(widget.group.id!);
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

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final currentUser = context.read<AuthProvider>().currentUser;
                    final isOwnMessage = message.senderId == currentUser?.id.toString();

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
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final currentUser = authProvider.currentUser;
              if (currentUser == null) return const SizedBox.shrink();

              return MessageInput(
                textController: _messageController,
                onSendMessage: (content) => _sendMessage(
                  currentUser.id.toString(),
                  currentUser.displayName,
                  content,
                ),
                onSendAttachment: () => _sendAttachment(currentUser.id.toString(), currentUser.displayName),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String senderId, String senderName, String content) async {
    if (content.trim().isEmpty) return;

    await context.read<ChatProvider>().sendMessage(
      groupId: widget.group.id!,
      senderId: senderId,
      senderName: senderName,
      content: content.trim(),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendAttachment(String senderId, String senderName) {
    // TODO: Implement file attachment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File attachment coming soon!')),
    );
  }
}