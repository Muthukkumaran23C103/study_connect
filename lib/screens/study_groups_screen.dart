import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/models/study_group_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCreateDialog = false;

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StudyGroupProvider>().loadGroups();
            },
          ),
        ],
      ),
      body: Consumer<StudyGroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${groupProvider.errorMessage}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => groupProvider.loadGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Search Groups',
                  hintText: 'Enter group name or category',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      groupProvider.loadGroups();
                    } else {
                      groupProvider.searchGroups(value);
                    }
                  },
                ),
              ),

              // Groups List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => groupProvider.loadGroups(),
                  child: groupProvider.groups.isEmpty
                      ? const Center(
                    child: Text(
                      'No study groups found.\nCreate one to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return _buildGroupCard(context, group);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, StudyGroup group) {
    final groupProvider = context.watch<StudyGroupProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final currentUserId = currentUser?.id?.toString() ?? '';

    final isMember = groupProvider.isUserInGroup(group.id!, currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to group details or chat
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: group,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Group Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getGroupCategoryColor(group.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getGroupCategoryIcon(group.category),
                      color: _getGroupCategoryColor(group.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Group Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.memberCount} members',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Join/Leave Button
                  if (currentUser != null) ...[
                    if (isMember)
                      OutlinedButton(
                        onPressed: () => _leaveGroup(group),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                        ),
                        child: const Text('Leave'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _joinGroup(group),
                        child: const Text('Join'),
                      ),
                  ],
                ],
              ),

              if (group.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  group.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              Row(
                children: [
                  // Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGroupCategoryColor(group.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getGroupCategoryColor(group.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${group.memberCount} members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinGroup(StudyGroup group) async {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<StudyGroupProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final currentUserId = currentUser.id.toString();

    try {
      await groupProvider.joinGroup(group.id!, currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined ${group.name} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup(StudyGroup group) async {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<StudyGroupProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final currentUserId = currentUser.id.toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave ${group.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await groupProvider.leaveGroup(group.id!, currentUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left ${group.name} successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to leave group: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'AI';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Study Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Group Name',
                  hintText: 'Enter group name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description',
                  hintText: 'Enter group description',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['AI', 'Mobile Development', 'Operating Systems']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<StudyGroupProvider>(
              builder: (context, groupProvider, child) => ElevatedButton(
                onPressed: groupProvider.isLoading
                    ? null
                    : () async {
                  if (nameController.text.isNotEmpty) {
                    try {
                      await groupProvider.createGroup(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        selectedCategory,
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Study group created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create group: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: groupProvider.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGroupCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ai':
        return Colors.purple;
      case 'mobile development':
        return Colors.blue;
      case 'operating systems':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getGroupCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ai':
        return Icons.psychology;
      case 'mobile development':
        return Icons.phone_android;
      case 'operating systems':
        return Icons.computer;
      default:
        return Icons.group;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}