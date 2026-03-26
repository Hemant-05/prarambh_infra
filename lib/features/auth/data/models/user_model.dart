class UserModel {
  final int id;
  final String email;
  final String phone;
  final String role; // 'Advisor' or 'Admin'
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? token; // We store the auth token here

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.token,
  });

  // Notice we pass the token as an optional parameter since it sits outside the 'user' object in the JSON
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'Advisor',
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      token: token,
    );
  }
}