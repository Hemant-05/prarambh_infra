class AdvisorLeaderboardModel {
  final int id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String? profilePhoto;
  final double totalSales; // This was maped from 'total_sales' previously
  final double totalRevenue;
  final int teamSize;
  final int rank;
  final double attendancePercentage;
  final int totalDeals;

  AdvisorLeaderboardModel({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.designation,
    this.profilePhoto,
    required this.totalSales,
    required this.totalRevenue,
    required this.teamSize,
    required this.rank,
    required this.attendancePercentage,
    required this.totalDeals,
  });

  factory AdvisorLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return AdvisorLeaderboardModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      advisorCode: json['Advisor_code']?.toString() ?? json['advisor_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Unknown',
      designation: json['designation']?.toString() ?? 'Advisor',
      profilePhoto: json['profile_photo']?.toString(),
      totalSales: double.tryParse(json['total_sales']?.toString() ?? '0') ?? 0,
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      teamSize: json['team_size'] is int ? json['team_size'] : int.tryParse(json['team_size']?.toString() ?? '0') ?? 0,
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      attendancePercentage: double.tryParse(json['attendance_percentage']?.toString() ?? '0') ?? 0.0,
      totalDeals: json['total_deals'] is int ? json['total_deals'] : int.tryParse(json['total_deals']?.toString() ?? '0') ?? 0,
    );
  }

  String get avatarUrl {
    if (profilePhoto == null || profilePhoto!.isEmpty) return '';
    if (profilePhoto!.startsWith('http')) return profilePhoto!;
    const String baseUrl = "https://workiees.com/";
    return baseUrl + (profilePhoto!.startsWith('/') ? profilePhoto!.substring(1) : profilePhoto!);
  }

  String get formattedRevenue {
    if (totalRevenue >= 100000) {
      return "₹${(totalRevenue / 100000).toStringAsFixed(1)}L";
    } else if (totalRevenue >= 1000) {
      return "₹${(totalRevenue / 1000).toStringAsFixed(1)}K";
    }
    return "₹${totalRevenue.toStringAsFixed(0)}";
  }
}
