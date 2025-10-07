import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/models/study_group_model.dart';
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    await context.read<ChatProvider>().sendMessage(
      groupId: widget.group.id!,
      senderId: currentUser.id.toString(),
      senderName: currentUser.displayName,
      content: content,
    );

    _scrollToBottom();
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show group info
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
                        Text('Error: ${chatProvider.errorMessage}'),
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
                final currentUser = authProvider.currentUser;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to start the conversation!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwn = message.senderId == currentUser?.id.toString();

                    return MessageBubble(
                      message: message,
                      isOwn: isOwn,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: MessageInput(
              textController: _messageController,
              onSendMessage: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}