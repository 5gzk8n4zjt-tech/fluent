enum Role { user, admin }

class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.level,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final Role role;
  final String? level;
  final DateTime createdAt;

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      role: map['role'] == 'admin' ? Role.admin : Role.user,
      level: map['level'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
