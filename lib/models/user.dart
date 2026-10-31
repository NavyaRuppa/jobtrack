class User {
  final String id;
  final String email;
  final String password;
  final String role; // 'student' or 'admin'
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
