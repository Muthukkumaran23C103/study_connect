class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String category;
  final String adminId;
  final DateTime createdAt;
  final int memberCount;
  final bool isPrivate;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.adminId,
    required this.createdAt,
    this.memberCount = 1,
    this.isPrivate = false,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      adminId: map['admin_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      memberCount: map['member_count'] as int? ?? 1,
      isPrivate: (map['is_private'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'admin_id': adminId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'member_count': memberCount,
      'is_private': isPrivate ? 1 : 0,
    };
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? adminId,
    DateTime? createdAt,
    int? memberCount,
    bool? isPrivate,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
