import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StudyGroupProvider>().loadUserGroups(currentUser.id.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view chats'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
        actions: [
          Consumer<StudyGroupProvider>(
            builder: (context, groupProvider, child) {
              return IconButton(
                onPressed: () {
                  groupProvider.loadUserGroups(currentUser.id.toString());
                },
                icon: groupProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Consumer<StudyGroupProvider>(
        builder: (context, groupProvider, child) {
          // Error handling
          if (groupProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: ${groupProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      groupProvider.loadUserGroups(currentUser.id.toString());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Loading state
          if (groupProvider.isLoading && groupProvider.userGroups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          if (groupProvider.userGroups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join some study groups to start chatting!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Groups list
          return RefreshIndicator(
            onRefresh: () async {
              await groupProvider.loadUserGroups(currentUser.id.toString());
            },
            child: ListView.builder(
              itemCount: groupProvider.userGroups.length,
              itemBuilder: (context, index) {
                final group = groupProvider.userGroups[index];
                return _buildChatItem(group);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(group) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Get last message for this group
        return FutureBuilder(
          future: chatProvider.getLastMessage(group.id!),
          builder: (context, snapshot) {
            final message = snapshot.data;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(group.category),
                child: Text(
                  group.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                group.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: message != null
                  ? Text(
                '${message.senderName}: ${message.content}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
                  : Text(
                '${group.memberCount} members',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: message != null
                  ? Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(group: group),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ai':
        return Colors.purple;
      case 'mobile development':
        return Colors.blue;
      case 'operating systems':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
