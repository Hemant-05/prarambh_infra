class AdvisorNode {
  final String id;
  final String name;
  final String role; // 'Manager', 'SUP', 'ADV'
  final String code;
  final String avatarUrl;
  final List<AdvisorNode> children;

  AdvisorNode({
    required this.id, required this.name, required this.role,
    required this.code, required this.avatarUrl, this.children = const [],
  });

  factory AdvisorNode.fromJson(Map<String, dynamic> json) {
    return AdvisorNode(
      id: json['id']?.toString() ?? '', name: json['name'] ?? '',
      role: json['role'] ?? '', code: json['code'] ?? '', avatarUrl: json['avatar_url'] ?? '',
      children: (json['children'] as List<dynamic>?)?.map((e) => AdvisorNode.fromJson(e)).toList() ?? [],
    );
  }
}

class BrokerProfileModel {
  final String id;
  final String name;
  final String code;
  final String phone;
  final String email;
  final int age;
  final int suspectCount;
  final int prospectCount;
  final int negotCount;
  final int dealCount;
  final String personalSales;
  final String teamSales;
  final String status;
  // Note: For a production app, you would add sub-models for Documents, Contests, etc.

  BrokerProfileModel({
    required this.id, required this.name, required this.code, required this.phone,
    required this.email, required this.age, required this.suspectCount,
    required this.prospectCount, required this.negotCount, required this.dealCount,
    required this.personalSales, required this.teamSales, required this.status,
  });

  factory BrokerProfileModel.fromJson(Map<String, dynamic> json) => BrokerProfileModel(
    id: json['id']?.toString() ?? '', name: json['name'] ?? '', code: json['code'] ?? '',
    phone: json['phone'] ?? '', email: json['email'] ?? '', age: json['age'] ?? 0,
    suspectCount: json['suspect_count'] ?? 0, prospectCount: json['prospect_count'] ?? 0,
    negotCount: json['negot_count'] ?? 0, dealCount: json['deal_count'] ?? 0,
    personalSales: json['personal_sales'] ?? '0', teamSales: json['team_sales'] ?? '0',
    status: json['status'] ?? 'Active',
  );
}