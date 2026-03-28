class RecruitmentDashboardModel {
  final int totalBrokers;
  final int activeBrokers;
  final int pendingBrokers;
  final int suspendedBrokers;
  final List<RecruitedAdvisorModel> recentRecruitments;

  RecruitmentDashboardModel({
    required this.totalBrokers,
    required this.activeBrokers,
    required this.pendingBrokers,
    required this.suspendedBrokers,
    required this.recentRecruitments,
  });

  factory RecruitmentDashboardModel.fromJson(Map<String, dynamic> json) {
    return RecruitmentDashboardModel(
      totalBrokers: json['total_brokers'] ?? 0,
      activeBrokers: json['active_brokers'] ?? 0,
      pendingBrokers: json['pending_brokers'] ?? 0,
      suspendedBrokers: json['suspended_brokers'] ?? 0,
      recentRecruitments: (json['recent_recruitments'] as List?)
          ?.map((e) => RecruitedAdvisorModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class RecruitedAdvisorModel {
  final String id;
  final String name;
  final String dateJoined;
  final String status; // Active, Pending, Suspended
  final String? imageUrl;

  RecruitedAdvisorModel({
    required this.id,
    required this.name,
    required this.dateJoined,
    required this.status,
    this.imageUrl,
  });

  factory RecruitedAdvisorModel.fromJson(Map<String, dynamic> json) {
    return RecruitedAdvisorModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      dateJoined: json['date_joined'] ?? '',
      status: json['status'] ?? 'Pending',
      imageUrl: json['image_url'],
    );
  }
}