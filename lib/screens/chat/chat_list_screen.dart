import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/models/study_group_model.dart';
import '../chat/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final currentUser = authProvider.currentUser;
              if (currentUser == null) return const SizedBox.shrink();

              return IconButton(
                onPressed: () {
                  context.read<StudyGroupProvider>().loadUserGroups(currentUser.id.toString());
                },
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Consumer2<StudyGroupProvider, AuthProvider>(
        builder: (context, groupProvider, authProvider, child) {
          final currentUser = authProvider.currentUser;
          if (currentUser == null) {
            return const Center(child: Text('Please log in to view chats'));
          }

          if (groupProvider.isLoading && groupProvider.userGroups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.errorMessage != null) {
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
                  Text('Error: \${groupProvider.errorMessage}'),
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

          return RefreshIndicator(
            onRefresh: () async {
              await groupProvider.loadUserGroups(currentUser.id.toString());
            },
            child: groupProvider.userGroups.isEmpty
                ? const Center(child: Text('No chats yet. Join a study group to start chatting!'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
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

  Widget _buildChatListItem(BuildContext context, StudyGroup group) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final lastMessage = chatProvider.getLastMessage(group.id!);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                group.name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              group.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: FutureBuilder<Object?>(
              future: lastMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final message = snapshot.data as dynamic;
                  return Text(
                    'Last message preview',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            trailing: const Icon(Icons.chevron_right),
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