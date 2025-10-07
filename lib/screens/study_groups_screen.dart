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
  final _searchController = TextEditingController();
  bool _showOnlyJoinedGroups = false;

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
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Consumer<StudyGroupProvider>(
        builder: (context, groupProvider, child) {
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
                  Text(
                    'Error: ${groupProvider.errorMessage}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => groupProvider.loadGroups(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading study groups...'),
                ],
              ),
            );
          }

          final displayGroups = _showOnlyJoinedGroups
              ? groupProvider.userGroups
              : groupProvider.groups;

          return Column(
            children: [
              // Search and Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _searchController,
                      hintText: 'Search study groups...',
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (query) {
                        if (query.isNotEmpty) {
                          groupProvider.searchGroups(query);
                        } else {
                          groupProvider.loadGroups();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilterChip(
                            label: const Text('My Groups'),
                            selected: _showOnlyJoinedGroups,
                            onSelected: (selected) {
                              setState(() {
                                _showOnlyJoinedGroups = selected;
                              });
                              if (selected && currentUser != null) {
                                groupProvider.loadUserGroups(currentUser.id.toString());
                              } else {
                                groupProvider.loadGroups();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Groups List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => groupProvider.loadGroups(),
                  child: displayGroups.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showOnlyJoinedGroups ? Icons.group_off : Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showOnlyJoinedGroups
                              ? 'You haven\'t joined any groups yet'
                              : 'No study groups found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (!_showOnlyJoinedGroups) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to create one!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayGroups.length,
                    itemBuilder: (context, index) {
                      final group = displayGroups[index];
                      return _buildGroupCard(context, group, currentUser);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, StudyGroup group, dynamic currentUser) {
    final groupProvider = context.watch<StudyGroupProvider>();
    final isMember = currentUser != null ? groupProvider.isUserInGroup(group.id!, currentUser.id.toString()) : false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isMember
            ? () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(group: group),
          ),
        )
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getCategoryColor(group.category),
                    child: Icon(
                      _getCategoryIcon(group.category),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${group.memberCount} members',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButton(context, group, isMember),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(group.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      group.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getCategoryColor(group.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isMember) ...[
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Joined',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, StudyGroup group, bool isMember) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final groupProvider = context.read<StudyGroupProvider>();

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return isMember
        ? OutlinedButton(
      onPressed: () async {
        final currentUserId = currentUser.id.toString();
        await groupProvider.leaveGroup(group.id!, currentUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Left ${group.name}')),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      child: const Text('Leave'),
    )
        : ElevatedButton(
      onPressed: () async {
        final currentUserId = currentUser.id.toString();
        await groupProvider.joinGroup(group.id!, currentUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Joined ${group.name}')),
          );
        }
      },
      child: const Text('Join'),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ai':
        return Colors.purple;
      case 'mobile development':
        return Colors.blue;
      case 'operating systems':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
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

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'AI';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Study Group'),
          content: Column(
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
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'AI', child: Text('AI')),
                  DropdownMenuItem(value: 'Mobile Development', child: Text('Mobile Development')),
                  DropdownMenuItem(value: 'Operating Systems', child: Text('Operating Systems')),
                ],
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
                if (nameController.text.isNotEmpty) {
                  final groupProvider = context.read<StudyGroupProvider>();
                  await groupProvider.createGroup(
                    nameController.text,
                    descriptionController.text,
                    selectedCategory,
                  );

                  nameController.clear();
                  descriptionController.clear();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Study group created successfully!')),
                    );
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
}