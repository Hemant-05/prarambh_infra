class RecruitmentDashboardModel {
  final LeaderInfoModel leaderInfo;
  final RecruitmentStatsModel stats;
  final List<RecruitedAdvisorModel> teamMembers;

  RecruitmentDashboardModel({
    required this.leaderInfo,
    required this.stats,
    required this.teamMembers,
  });

  factory RecruitmentDashboardModel.fromJson(Map<String, dynamic> json) {
    return RecruitmentDashboardModel(
      leaderInfo: LeaderInfoModel.fromJson(json['leader_info'] ?? {}),
      stats: RecruitmentStatsModel.fromJson(json['recruitment_stats'] ?? {}),
      teamMembers: (json['team_members'] as List?)
          ?.map((e) => RecruitedAdvisorModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class LeaderInfoModel {
  final int id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String status;
  final String imageUrl;

  LeaderInfoModel({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.designation,
    required this.status,
    required this.imageUrl,
  });

  factory LeaderInfoModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://workiees.com/";
    String rawPath = json['profile_photo']?.toString() ?? '';
    String finalUrl = rawPath.startsWith('http') ? rawPath : (rawPath.isNotEmpty ? baseUrl + (rawPath.startsWith('/') ? rawPath.substring(1) : rawPath) : '');

    return LeaderInfoModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      advisorCode: json['Advisor_code']?.toString() ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      designation: json['designation'] ?? 'Advisor',
      status: json['status'] ?? 'Active',
      imageUrl: finalUrl,
    );
  }
}

class RecruitmentStatsModel {
  final int totalRecruits;
  final int activeRecruits;
  final int pendingRecruits;
  final int inactiveRecruits;

  RecruitmentStatsModel({
    required this.totalRecruits,
    required this.activeRecruits,
    required this.pendingRecruits,
    required this.inactiveRecruits,
  });

  factory RecruitmentStatsModel.fromJson(Map<String, dynamic> json) {
    return RecruitmentStatsModel(
      totalRecruits: json['total_recruits'] != null ? int.tryParse(json['total_recruits'].toString()) ?? 0 : 0,
      activeRecruits: json['active_recruits'] != null ? int.tryParse(json['active_recruits'].toString()) ?? 0 : 0,
      pendingRecruits: json['pending_recruits'] != null ? int.tryParse(json['pending_recruits'].toString()) ?? 0 : 0,
      inactiveRecruits: json['inactive_recruits'] != null ? int.tryParse(json['inactive_recruits'].toString()) ?? 0 : 0,
    );
  }
}

class RecruitedAdvisorModel {
  final int id;
  final String advisorCode;
  final String name;
  final String designation;
  final String dateJoined;
  final String status;
  final String imageUrl;

  RecruitedAdvisorModel({
    required this.id,
    required this.advisorCode,
    required this.name,
    required this.designation,
    required this.dateJoined,
    required this.status,
    required this.imageUrl,
  });

  factory RecruitedAdvisorModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://workiees.com/";
    String rawPath = json['profile_photo']?.toString() ?? '';
    String finalUrl = rawPath.startsWith('http') ? rawPath : (rawPath.isNotEmpty ? baseUrl + (rawPath.startsWith('/') ? rawPath.substring(1) : rawPath) : '');

    // Format date nicely
    String rawDate = json['created_at']?.toString().split(' ')[0] ?? '';

    return RecruitedAdvisorModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      advisorCode: json['Advisor_code']?.toString() ?? '',
      name: json['full_name'] ?? 'Unknown',
      designation: json['designation'] ?? 'Advisor',
      dateJoined: rawDate,
      status: json['status'] ?? 'Pending',
      imageUrl: finalUrl,
    );
  }
}