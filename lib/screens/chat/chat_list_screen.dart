import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/study_group_provider.dart';
import '../providers/chat_provider.dart';
import '../models/study_group_model.dart';
import '../chat/chat_screen.dart';
import '../../widgets/common/custom_button.dart';

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
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        context.read<StudyGroupProvider>().loadUserGroups(currentUser.id.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final currentUser = authProvider.currentUser;
              return IconButton(
                onPressed: currentUser != null
                    ? () {
                  context.read<StudyGroupProvider>().loadUserGroups(currentUser.id.toString());
                }
                    : null,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: Consumer2<StudyGroupProvider, AuthProvider>(
        builder: (context, groupProvider, authProvider, child) {
          final currentUser = authProvider.currentUser;

          if (currentUser == null) {
            return const Center(
              child: Text('Please log in to view your chats'),
            );
          }

          if (groupProvider.isLoading && groupProvider.userGroups.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (groupProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${groupProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Retry',
                    type: ButtonType.primary,
                    onPressed: () {
                      groupProvider.loadUserGroups(currentUser.id.toString());
                    },
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await groupProvider.loadUserGroups(currentUser.id.toString());
            },
            child: groupProvider.userGroups.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: groupProvider.userGroups.length,
              itemBuilder: (context, index) {
                final group = groupProvider.userGroups[index];
                return _buildChatListItem(context, group);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join a study group to start chatting!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Browse Groups',
            type: ButtonType.primary,
            onPressed: () {
              // Navigate to study groups tab
              final tabController = context.findAncestorStateOfType<DefaultTabController>();
              tabController?.setState(() {
                DefaultTabController.of(context).animateTo(0);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, StudyGroup group) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Get last message for this group
        final lastMessage = chatProvider.getLastMessage(group.id!);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: group.imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  group.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 20,
                    );
                  },
                ),
              )
                  : Icon(
                Icons.group,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              group.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: FutureBuilder<dynamic>(
              future: lastMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final message = snapshot.data;
                  return Text(
                    '${message.senderName}: ${message.content}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  );
                } else {
                  return Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  );
                }
              },
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${group.memberCount} members',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(group: group),
                ),
              );
            },
          ),
        );
      },
    );
  }
}