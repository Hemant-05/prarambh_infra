class TopPerformerModel {
  final int id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String profilePhoto;
  final int totalDeals;
  final double totalRevenue;

  TopPerformerModel({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.designation,
    required this.profilePhoto,
    required this.totalDeals,
    required this.totalRevenue,
  });

  factory TopPerformerModel.fromJson(Map<String, dynamic> json) {
    return TopPerformerModel(
      id: json['id'] ?? 0,
      advisorCode: json['Advisor_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Unknown',
      designation: json['designation']?.toString() ?? 'Advisor',
      profilePhoto: json['profile_photo']?.toString() ?? '',
      totalDeals: json['total_deals'] != null ? int.tryParse(json['total_deals'].toString()) ?? 0 : 0,
      totalRevenue: json['total_revenue'] != null ? double.tryParse(json['total_revenue'].toString()) ?? 0.0 : 0.0,
    );
  }
}
