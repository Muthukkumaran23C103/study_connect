class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String category;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    this.memberCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isPublic': isPublic ? 1 : 0,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      isPublic: (map['isPublic'] ?? 1) == 1,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      memberCount: map['memberCount'] ?? 0,
    );
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    bool? isPublic,
    String? createdBy,
    DateTime? createdAt,
    int? memberCount,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}