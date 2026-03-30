class AdvisorNode {
  final String id;
  final String name;
  final String role;
  final String code;
  final String avatarUrl;
  final List<AdvisorNode> children;

  AdvisorNode({
    required this.id, required this.name, required this.role,
    required this.code, required this.avatarUrl, this.children = const [],
  });

  factory AdvisorNode.fromJson(Map<String, dynamic> json) {
    // Sometimes backend returns 'team_members' instead of 'children'
    var childrenList = json['children'] ?? json['team_members'];

    return AdvisorNode(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      role: json['role'] ?? json['designation'] ?? '',
      code: json['code'] ?? json['Advisor_code'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['profile_photo'] ?? '',
      children: (childrenList as List<dynamic>?)?.map((e) => AdvisorNode.fromJson(e)).toList() ?? [],
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

  BrokerProfileModel({
    required this.id, required this.name, required this.code, required this.phone,
    required this.email, required this.age, required this.suspectCount,
    required this.prospectCount, required this.negotCount, required this.dealCount,
    required this.personalSales, required this.teamSales, required this.status,
  });

  factory BrokerProfileModel.fromJson(Map<String, dynamic> json) => BrokerProfileModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? json['full_name'] ?? '',
    code: json['code'] ?? json['Advisor_code'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    age: json['age'] != null ? int.tryParse(json['age'].toString()) ?? 0 : 0,
    suspectCount: json['suspect_count'] ?? 0,
    prospectCount: json['prospect_count'] ?? 0,
    negotCount: json['negot_count'] ?? 0,
    dealCount: json['deal_count'] ?? 0,
    personalSales: json['personal_sales']?.toString() ?? '0',
    teamSales: json['team_sales']?.toString() ?? '0',
    status: json['status'] ?? 'Active',
  );
}