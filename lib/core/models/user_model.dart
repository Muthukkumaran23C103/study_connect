class UserModel {
  final int? id;
  final String email;
  final String password;
  final String displayName;
  final String? college;
  final String? year;
  final String? branch;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime? lastActive;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.displayName,
    this.college,
    this.year,
    this.branch,
    this.avatarPath,
    required this.createdAt,
    this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'displayName': displayName,
      'college': college,
      'year': year,
      'branch': branch,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      displayName: map['displayName'] ?? '',
      college: map['college'],
      year: map['year'],
      branch: map['branch'],
      avatarPath: map['avatarPath'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'])
          : null,
    );
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? password,
    String? displayName,
    String? college,
    String? year,
    String? branch,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      college: college ?? this.college,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
