import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/models/study_group_model.dart';
import '../../widgets/common/custom_text_field.dart';

class StudyGroupsScreen extends StatefulWidget {
  @override
  _StudyGroupsScreenState createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StudyGroupProvider>().loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      body: Consumer<StudyGroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (groupProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${groupProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => groupProvider.loadGroups(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final groups = groupProvider.groups;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Search Groups',
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      groupProvider.searchGroups(value);
                    } else {
                      groupProvider.loadGroups();
                    }
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => groupProvider.loadGroups(),
                  child: groups.isEmpty
                      ? Center(child: Text('No groups found'))
                      : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _buildGroupCard(context, group);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, StudyGroup group) {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<StudyGroupProvider>();
    final currentUser = authProvider.currentUser;

    final isMember = groupProvider.isUserInGroup(group.id!, currentUser?.id.toString() ?? '');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(_getCategoryIcon(group.category)),
                  backgroundColor: _getCategoryColor(group.category),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${group.memberCount} members',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(group.category),
                  backgroundColor: _getCategoryColor(group.category),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              group.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isMember)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {'group': group},
                    ),
                    icon: Icon(Icons.chat),
                    label: Text('Chat'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _joinGroup(context, group),
                    child: Text('Join'),
                  ),
                SizedBox(width: 8),
                Text('${group.memberCount} members'),
              ],
            ),
          ],
        ),
      ),
    );
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ai':
        return Colors.purple.shade100;
      case 'mobile development':
        return Colors.blue.shade100;
      case 'operating systems':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Future<void> _joinGroup(BuildContext context, StudyGroup group) async {
    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<StudyGroupProvider>();
    final currentUser = authProvider.currentUser;
    final currentUserId = currentUser!.id.toString();

    await groupProvider.joinGroup(group.id!, currentUserId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined ${group.name}!')),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'General';
    final categories = ['AI', 'Mobile Development', 'Operating Systems', 'General'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create Study Group'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: 'Group Name',
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: descriptionController,
                      label: 'Description',
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      final groupProvider = context.read<StudyGroupProvider>();
                      await groupProvider.createGroup(
                        nameController.text,
                        descriptionController.text,
                        selectedCategory,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Group created successfully!')),
                      );
                    }
                  },
                  child: Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSearchFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: Text('Filter by Category'),
                leading: Icon(Icons.filter_list),
              ),
              ListTile(
                title: Text('All Categories'),
                onTap: () {
                  context.read<StudyGroupProvider>().loadGroups();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('AI'),
                onTap: () {
                  context.read<StudyGroupProvider>().searchGroups('AI');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}