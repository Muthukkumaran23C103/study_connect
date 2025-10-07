import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/models/study_group_model.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search groups...',
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

          // Groups List
          Consumer<StudyGroupProvider>(
            builder: (context, groupProvider, child) {
              // FIXED: Use errorMessage instead of error
              if (groupProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${groupProvider.errorMessage}', // FIXED: errorMessage
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
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

              if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () => groupProvider.loadGroups(),
                  child: groupProvider.groups.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 64),
                        SizedBox(height: 16),
                        Text('No study groups found'),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return _buildGroupCard(context, group);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, StudyGroup group) {
    return Consumer<StudyGroupProvider>(
      builder: (context, groupProvider, child) {
        final currentUser = context.watch<AuthProvider>().currentUser;
        // FIXED: Pass both parameters
        final isMember = groupProvider.isUserInGroup(group.id!, currentUser?.id.toString() ?? '');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              if (isMember) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(group: group),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getCategoryColor(group.category),
                        child: Icon(
                          _getCategoryIcon(group.category),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
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
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMember)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Joined',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    group.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(group.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          group.category,
                          style: TextStyle(
                            color: _getCategoryColor(group.category),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isMember)
                        TextButton(
                          onPressed: () => _leaveGroup(context, group),
                          child: const Text('Leave'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => _joinGroup(context, group),
                          child: const Text('Join'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _joinGroup(BuildContext context, StudyGroup group) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final groupProvider = context.read<StudyGroupProvider>();
    final currentUserId = currentUser.id.toString(); // FIXED: Convert to string

    try {
      // FIXED: Pass string userId
      await groupProvider.joinGroup(group.id!, currentUserId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined ${group.name} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup(BuildContext context, StudyGroup group) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave ${group.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final groupProvider = context.read<StudyGroupProvider>();

      try {
        await groupProvider.leaveGroup(group.id!, currentUser.id.toString());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left ${group.name}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
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

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Study Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Group name',
                label: 'Name',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Group description',
                label: 'Description',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'AI', child: Text('AI')),
                  DropdownMenuItem(value: 'Mobile Development', child: Text('Mobile Development')),
                  DropdownMenuItem(value: 'Operating Systems', child: Text('Operating Systems')),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty &&
                  _selectedCategory != null) {
                // FIXED: Pass exactly 3 arguments as required
                await context.read<StudyGroupProvider>().createGroup(
                  _nameController.text,
                  _descriptionController.text,
                  _selectedCategory!,
                );

                _nameController.clear();
                _descriptionController.clear();
                _selectedCategory = null;

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'AI':
        return Colors.purple;
      case 'Mobile Development':
        return Colors.blue;
      case 'Operating Systems':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'AI':
        return Icons.psychology;
      case 'Mobile Development':
        return Icons.phone_android;
      case 'Operating Systems':
        return Icons.computer;
      default:
        return Icons.group;
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