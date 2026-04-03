class AdminEnquiryModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String iWantTo;
  final String message;
  final String status;
  final String createdAt;

  AdminEnquiryModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.iWantTo,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory AdminEnquiryModel.fromJson(Map<String, dynamic> json) {
    return AdminEnquiryModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      iWantTo: json['i_want_to'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at']?.toString().split(' ')[0] ?? '',
    );
  }
}

class AdminCareerEnquiryModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String description;
  final String status;
  final String createdAt;

  AdminCareerEnquiryModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory AdminCareerEnquiryModel.fromJson(Map<String, dynamic> json) {
    return AdminCareerEnquiryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at']?.toString().split(' ')[0] ?? '',
    );
  }
}
