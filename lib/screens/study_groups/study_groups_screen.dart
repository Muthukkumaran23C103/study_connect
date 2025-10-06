import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/study_group_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/study_group_model.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyGroupProvider>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(context),
          ),
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
                    onPressed: () => groupProvider.loadGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final groups = groupProvider.groups;

          if (groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No study groups found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first group to get started!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => groupProvider.loadGroups(),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return _buildGroupCard(context, group);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, StudyGroup group) {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<StudyGroupProvider>();
    final currentUserId = authProvider.currentUser?.id.toString() ?? '';
    final isMember = groupProvider.isUserInGroup(group.id!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(group.category),
          child: Icon(
            _getCategoryIcon(group.category),
            color: Colors.white,
          ),
        ),
        title: Text(group.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount} members',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  group.category,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: isMember
            ? IconButton(
          icon: const Icon(Icons.chat, color: Colors.blue),
          onPressed: () {
            Navigator.pushNamed(context, '/chat/${group.id}');
          },
        )
            : TextButton(
          onPressed: () => _joinGroup(context, group),
          child: const Text('Join'),
        ),
        onTap: () {
          if (isMember) {
            Navigator.pushNamed(context, '/chat/${group.id}');
          } else {
            _showGroupDetailsDialog(context, group);
          }
        },
      ),
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

  Future<void> _joinGroup(BuildContext context, StudyGroup group) async {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<StudyGroupProvider>();
    final currentUserId = int.parse(authProvider.currentUser?.id.toString() ?? '0');

    try {
      await groupProvider.joinGroup(group.id!, currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined ${group.name} successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join group: $e')),
        );
      }
    }
  }

  void _showGroupDetailsDialog(BuildContext context, StudyGroup group) {
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _joinGroup(context, group);
            },
            child: const Text('Join Group'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'AI';
    final categories = ['AI', 'Mobile Dev', 'OS', 'Other'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Study Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  final authProvider = context.read<AuthProvider>();
                  final groupProvider = context.read<StudyGroupProvider>();
                  final currentUserId = int.parse(authProvider.currentUser?.id.toString() ?? '0');

                  try {
                    await groupProvider.createGroup(
                      nameController.text,
                      descriptionController.text,
                      selectedCategory,
                      currentUserId,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Group created successfully!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create group: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Groups'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search by name or category',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              context.read<StudyGroupProvider>().searchGroups(query);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text;
              if (query.isNotEmpty) {
                context.read<StudyGroupProvider>().searchGroups(query);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
