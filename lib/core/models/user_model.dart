class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? college;
  final String? year;
  final String? branch;
  final List<String> joinedGroups;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.college,
    this.year,
    this.branch,
    this.joinedGroups = const [],
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'college': college,
      'year': year,
      'branch': branch,
      'joined_groups': joinedGroups.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_verified': isVerified ? 1 : 0,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      college: map['college'] as String?,
      year: map['year'] as String?,
      branch: map['branch'] as String?,
      joinedGroups: map['joined_groups'] != null
          ? (map['joined_groups'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      isVerified: (map['is_verified'] as int?) == 1,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? college,
    String? year,
    String? branch,
    List<String>? joinedGroups,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      college: college ?? this.college,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      joinedGroups: joinedGroups ?? this.joinedGroups,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
