import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _StudyGroupsPage(),
    const _ChatsPage(),
    const _NotesPage(),
    const _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyConnect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'profile') {
                context.go(AppRoutes.profile);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Study Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}

class _StudyGroupsPage extends StatelessWidget {
  const _StudyGroupsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Study Groups',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Recommended Groups
          Text(
            'Recommended',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: [
                _StudyGroupCard(
                  name: 'AI Study Group',
                  description: 'Machine Learning & Artificial Intelligence',
                  memberCount: 45,
                  tags: ['AI', 'ML', 'Python'],
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _StudyGroupCard(
                  name: 'Mobile Dev Group',
                  description: 'Flutter, React Native, Android & iOS',
                  memberCount: 32,
                  tags: ['Flutter', 'React Native', 'Mobile'],
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _StudyGroupCard(
                  name: 'OS Study Group',
                  description: 'Operating Systems concepts',
                  memberCount: 28,
                  tags: ['OS', 'Linux', 'Systems'],
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _StudyGroupCard(
                  name: 'Placement Prep',
                  description: 'Interview preparation and practice',
                  memberCount: 156,
                  tags: ['Interview', 'DSA', 'Coding'],
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyGroupCard extends StatelessWidget {
  final String name;
  final String description;
  final int memberCount;
  final List<String> tags;
  final VoidCallback onTap;

  const _StudyGroupCard({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.group,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tags
              Wrap(
                spacing: 8,
                children: tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 8),

              // Member count
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$memberCount members',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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
}

class _ChatsPage extends StatelessWidget {
  const _ChatsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Chats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Join study groups to start chatting',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesPage extends StatelessWidget {
  const _NotesPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Share notes in study groups',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(
            child: Text('No user data'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (user.college != null) ...[
                const SizedBox(height: 8),
                Text(
                  user.college!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(
                width: double.infinity,
                onPressed: () => context.go(AppRoutes.profile),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}