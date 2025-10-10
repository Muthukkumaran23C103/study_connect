class StudyGroupModel {
  final int? id;
  final String name;
  final String description;
  final String createdBy;
  final String? tags;
  final int memberCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StudyGroupModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    this.tags,
    this.memberCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory StudyGroupModel.fromMap(Map<String, dynamic> map) {
    return StudyGroupModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdBy: map['created_by'] as String? ?? '',
      tags: map['tags'] as String?,
      memberCount: map['member_count'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'tags': tags,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  StudyGroupModel copyWith({
    int? id,
    String? name,
    String? description,
    String? createdBy,
    String? tags,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
