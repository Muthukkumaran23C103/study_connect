class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final DateTime createdAt;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
