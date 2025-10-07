import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/study_group_provider.dart';
import '../models/study_group_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../chat/chat_screen.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyGroupProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Groups',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Create Group',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    label: 'Search',
                    hintText: 'Search study groups...',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<StudyGroupProvider>().loadGroups();
                      } else {
                        context.read<StudyGroupProvider>().searchGroups(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CustomButton(
                  text: 'Search',
                  type: ButtonType.primary,
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      context.read<StudyGroupProvider>().searchGroups(query);
                    } else {
                      context.read<StudyGroupProvider>().loadGroups();
                    }
                  },
                ),
              ],
            ),
          ),

          // Groups list
          Expanded(
            child: Consumer<StudyGroupProvider>(
              builder: (context, groupProvider, child) {
                if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
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
                          onPressed: () => groupProvider.loadGroups(),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => groupProvider.loadGroups(),
                  child: groupProvider.groups.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return _buildGroupCard(context, group, groupProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No study groups found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create the first group to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Group',
            type: ButtonType.primary,
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, StudyGroup group, StudyGroupProvider groupProvider) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isMember = groupProvider.isUserInGroup(group.id!, currentUser.id.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: group.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      group.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.group,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.memberCount} members',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              group.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Subject: ${group.subject}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                if (isMember) ...[
                  CustomButton(
                    text: 'Open Chat',
                    type: ButtonType.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(group: group),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  CustomButton(
                    text: 'Join Group',
                    type: ButtonType.secondary,
                    onPressed: () => _joinGroup(group, currentUser.id.toString()),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinGroup(StudyGroup group, String currentUserId) async {
    try {
      await context.read<StudyGroupProvider>().joinGroup(group.id!, currentUserId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined ${group.name}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join group: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedSubject = 'AI';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Study Group'),
          content: SizedBox(
            width: double.maxFinite,
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
                  hintText: 'Describe your study group',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'AI', child: Text('Artificial Intelligence')),
                    DropdownMenuItem(value: 'Mobile Dev', child: Text('Mobile Development')),
                    DropdownMenuItem(value: 'OS', child: Text('Operating Systems')),
                    DropdownMenuItem(value: 'General', child: Text('General')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSubject = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                descriptionController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final currentUser = authProvider.currentUser;

                return CustomButton(
                  text: 'Create',
                  type: ButtonType.primary,
                  onPressed: currentUser != null
                      ? () async {
                    if (nameController.text.trim().isNotEmpty &&
                        descriptionController.text.trim().isNotEmpty) {
                      await context.read<StudyGroupProvider>().createGroup(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        currentUser.id.toString(),
                      );

                      nameController.dispose();
                      descriptionController.dispose();
                      Navigator.pop(context);
                    }
                  }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}