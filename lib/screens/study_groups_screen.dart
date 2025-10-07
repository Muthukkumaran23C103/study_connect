import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../chat/chat_screen.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'AI';

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
        elevation: 0,
      ),
      body: Column(
        children: [
          // Error handling
          Consumer<StudyGroupProvider>(
            builder: (context, groupProvider, child) {
              if (groupProvider.errorMessage != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error: ${groupProvider.errorMessage}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => groupProvider.loadGroups(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    label: 'Search groups',
                    hint: 'Search by name or category',
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
                Consumer<StudyGroupProvider>(
                  builder: (context, groupProvider, child) {
                    return IconButton(
                      onPressed: () => groupProvider.loadGroups(),
                      icon: groupProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.refresh),
                    );
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (groupProvider.groups.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No study groups found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create the first study group!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => groupProvider.loadGroups(),
                  child: ListView.builder(
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return _buildGroupCard(group, groupProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupCard(group, StudyGroupProvider groupProvider) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final currentUserId = currentUser?.id.toString() ?? '';
    final isMember = groupProvider.isUserInGroup(group.id!, currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: isMember ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(group: group),
            ),
          );
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(group.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${group.memberCount} members',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                group.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _formatDate(group.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (currentUser != null)
                    ElevatedButton(
                      onPressed: () async {
                        if (isMember) {
                          await groupProvider.leaveGroup(group.id!, currentUserId);
                        } else {
                          await groupProvider.joinGroup(group.id!, currentUserId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMember ? Colors.red : null,
                        foregroundColor: isMember ? Colors.white : null,
                      ),
                      child: Text(isMember ? 'Leave' : 'Join'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  void _showCreateGroupDialog() {
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to create groups')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Study Group'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Group Name',
                hint: 'Enter group name',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your study group',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
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
                onChanged: (value) => setState(() => _selectedCategory = value!),
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
            builder: (context, groupProvider, child) {
              return ElevatedButton(
                onPressed: groupProvider.isLoading ? null : () async {
                  if (_nameController.text.trim().isEmpty ||
                      _descriptionController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  await groupProvider.createGroup(
                    _nameController.text.trim(),
                    _descriptionController.text.trim(),
                    _selectedCategory,
                  );

                  _nameController.clear();
                  _descriptionController.clear();
                  Navigator.of(context).pop();
                },
                child: groupProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
