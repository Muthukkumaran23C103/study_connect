class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String category;
  final bool isPublic;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isPublic = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isPublic': isPublic ? 1 : 0,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      isPublic: (map['isPublic'] ?? 1) == 1,
      createdBy: map['createdBy']?.toInt() ?? 0,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    bool? isPublic,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}