class AdminProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String avatarUrl;

  AdminProfileModel({
    required this.id, required this.name, required this.email,
    required this.phone, required this.role, required this.avatarUrl,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'Admin User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'Admin',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}