import 'package:flutter/material.dart';
import '../core/models/study_group_model.dart';

class StudyGroupsScreen extends StatelessWidget {
  const StudyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample study groups matching your wireframes
    final groups = [
      StudyGroup(
        id: 1,
        name: 'AI Study Group',
        description: 'Artificial Intelligence discussions',
        memberCount: 45,
        isPublic: true,
        createdAt: DateTime.now(),
      ),
      StudyGroup(
        id: 2,
        name: 'Mobile Dev Group',
        description: 'Mobile Development with Flutter & React Native',
        memberCount: 32,
        isPublic: true,
        createdAt: DateTime.now(),
      ),
      StudyGroup(
        id: 3,
        name: 'OS Study Group',
        description: 'Operating Systems concepts',
        memberCount: 28,
        isPublic: true,
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(group.name),
              ),
              title: Text(group.name),
              subtitle: Text(group.description),
              trailing: Text('${group.memberCount} members'),
              onTap: () {
                // Navigate to group details
                Navigator.pushNamed(context, '/chat', arguments: group.id);
              },
            ),
          );
        },
      ),
    );
  }
}
