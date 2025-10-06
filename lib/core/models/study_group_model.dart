class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String category;
  final String? iconPath;
  final DateTime createdAt;
  final int memberCount;
  final bool isPublic;
  final String? adminId;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconPath,
    required this.createdAt,
    this.memberCount = 0,
    this.isPublic = true,
    this.adminId,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      iconPath: map['icon_path'],
      createdAt: DateTime.parse(map['created_at']),
      memberCount: map['member_count'] ?? 0,
      isPublic: (map['is_public'] ?? 1) == 1,
      adminId: map['admin_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon_path': iconPath,
      'created_at': createdAt.toIso8601String(),
      'member_count': memberCount,
      'is_public': isPublic ? 1 : 0,
      'admin_id': adminId,
    };
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? iconPath,
    DateTime? createdAt,
    int? memberCount,
    bool? isPublic,
    String? adminId,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      isPublic: isPublic ?? this.isPublic,
      adminId: adminId ?? this.adminId,
    );
  }
}
