class AdvisorLeaderboardModel {
  final int id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String? profilePhoto;
  final double totalSales;

  AdvisorLeaderboardModel({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.designation,
    this.profilePhoto,
    required this.totalSales,
  });

  factory AdvisorLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return AdvisorLeaderboardModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      advisorCode: json['Advisor_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Unknown',
      designation: json['designation']?.toString() ?? 'Advisor',
      profilePhoto: json['profile_photo']?.toString(),
      totalSales: double.tryParse(json['total_sales']?.toString() ?? '0') ?? 0,
    );
  }
}
