import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/providers/study_group_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/models/study_group_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyGroupProvider>().loadUserGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Consumer<StudyGroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${groupProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => groupProvider.loadUserGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userGroups = groupProvider.userGroups;

          if (userGroups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join a study group to start chatting!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => groupProvider.loadUserGroups(),
            child: ListView.builder(
              itemCount: userGroups.length,
              itemBuilder: (context, index) {
                final group = userGroups[index];
                return _buildChatTile(context, group);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, StudyGroup group) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final lastMessage = chatProvider.getLastMessage(group.id!);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(group.category),
            child: Icon(
              _getCategoryIcon(group.category),
              color: Colors.white,
            ),
          ),
          title: Text(
            group.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: lastMessage != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${lastMessage.senderName}: ${lastMessage.content}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(lastMessage.timestamp),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          )
              : Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(height: 2),
              Text(
                '${group.memberCount}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/chat/${group.id}');
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'AI':
        return Colors.purple;
      case 'MOBILE DEV':
      case 'MOBILE':
        return Colors.blue;
      case 'OS':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'AI':
        return Icons.psychology;
      case 'MOBILE DEV':
      case 'MOBILE':
        return Icons.phone_android;
      case 'OS':
        return Icons.computer;
      default:
        return Icons.book;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Chats'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search by group name',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            // Implement search functionality if needed
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement search functionality
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
