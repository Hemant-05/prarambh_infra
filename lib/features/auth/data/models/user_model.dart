class UserModel {
  final int id;
  final String fullName;
  final String role;
  final String email;

  UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'Client',
      email: json['email'] ?? '',
    );
  }
}