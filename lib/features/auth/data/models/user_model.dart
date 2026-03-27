class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? advisorCode;
  final int? leaderId;
  final String? profilePhoto;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.advisorCode,
    this.leaderId,
    this.profilePhoto,
  });

  // Factory to handle both User JSON and Advisor JSON safely
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['full_name'] ?? json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'User',
      status: json['status'] ?? 'Active',
      advisorCode: json['Advisor_code'],
      leaderId: json['leader_id'] is int ? json['leader_id'] : int.tryParse(json['leader_id']?.toString() ?? ''),
      profilePhoto: json['profile_photo'],
    );
  }
}