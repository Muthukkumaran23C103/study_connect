import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/study_groups/group_card.dart';
import '../../widgets/study_groups/create_group_dialog.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({Key? key}) : super(key: key);

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = Provider.of<StudyGroupProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      groupProvider.loadStudyGroups();
      if (authProvider.currentUser != null) {
        groupProvider.loadUserGroups(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'StudyConnect',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar (matches wireframe)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      Provider.of<StudyGroupProvider>(context, listen: false)
                          .searchGroups(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Study Groups'),
                  Tab(text: 'My Groups'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllGroupsTab(),
          _buildMyGroupsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateGroupDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAllGroupsTab() {
    return Consumer<StudyGroupProvider>(
      builder: (context, groupProvider, child) {
        if (groupProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groupProvider.studyGroups.isEmpty) {
          return _buildEmptyState('No study groups found', Icons.groups_outlined);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recommended Section (matches wireframe)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Recommended',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Group Cards in Grid (3 per row as in wireframe)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: groupProvider.studyGroups.length,
                  itemBuilder: (context, index) {
                    final group = groupProvider.studyGroups[index];
                    return _buildGroupCard(group);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyGroupsTab() {
    return Consumer<StudyGroupProvider>(
      builder: (context, groupProvider, child) {
        if (groupProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groupProvider.userGroups.isEmpty) {
          return _buildEmptyState('You haven\'t joined any groups yet', Icons.group_add);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupProvider.userGroups.length,
          itemBuilder: (context, index) {
            final group = groupProvider.userGroups[index];
            return _buildMyGroupCard(group);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(dynamic group) {
    // Match the wireframe design with colored cards
    final colors = [
      Colors.blue!,
      Colors.green!,
      Colors.orange!,
      Colors.purple!,
    ];
    final color = colors[group.hashCode % colors.length];

    return GestureDetector(
      onTap: () {
        _navigateToGroupDetail(group);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Group Icon (as in wireframe)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getGroupIcon(group.name),
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              group.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${group.memberCount} members',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroupCard(dynamic group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            _getGroupIcon(group.name),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              group.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${group.memberCount} members',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToGroupDetail(group),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getGroupIcon(String groupName) {
    final name = groupName.toLowerCase();
    if (name.contains('ai') || name.contains('ml')) return Icons.psychology;
    if (name.contains('mobile') || name.contains('app')) return Icons.phone_android;
    if (name.contains('os') || name.contains('system')) return Icons.computer;
    if (name.contains('web')) return Icons.web;
    if (name.contains('data')) return Icons.storage;
    if (name.contains('java')) return Icons.code;
    if (name.contains('placement')) return Icons.work;
    return Icons.school;
  }

  void _navigateToGroupDetail(dynamic group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(group: group),
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

// Group Detail Screen (matches wireframe with tabs)
class GroupDetailScreen extends StatefulWidget {
  final dynamic group;

  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show group options
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'General Chat'),
            Tab(text: 'Notes'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralChatTab(),
          _buildNotesTab(),
          _buildQuizzesTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralChatTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('General Chat - Coming soon!'),
      ),
    );
  }

  Widget _buildNotesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Notes categories (as in wireframe)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2,
            children: [
              _buildNoteCategory('All Notes', Icons.note_outlined),
              _buildNoteCategory('Curated', Icons.star_outline),
              _buildNoteCategory('Books', Icons.book_outlined),
              _buildNoteCategory('Playlists', Icons.playlist_play),
              _buildNoteCategory('PYQ', Icons.quiz_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizzesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Quizzes - Coming soon!'),
      ),
    );
  }

  Widget _buildNoteCategory(String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to notes of this category
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                'Post',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
