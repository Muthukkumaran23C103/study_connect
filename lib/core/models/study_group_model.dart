class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String category;
  final int createdBy;
  final int memberCount;
  final DateTime createdAt;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdBy,
    this.memberCount = 0,
    required this.createdAt,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      createdBy: map['created_by'] ?? 0,
      memberCount: map['member_count'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'created_by': createdBy,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    int? createdBy,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}