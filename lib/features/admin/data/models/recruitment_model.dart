// The main dashboard data containing stats and the top recruiters
class RecruitmentDashboardModel {
  final int totalBrokers;
  final int activeBrokers;
  final int pendingVerification;
  final int suspendedActionReq;
  final List<RecruiterModel> topRecruiters;

  RecruitmentDashboardModel({
    required this.totalBrokers, required this.activeBrokers,
    required this.pendingVerification, required this.suspendedActionReq,
    required this.topRecruiters,
  });

  factory RecruitmentDashboardModel.fromJson(Map<String, dynamic> json) {
    return RecruitmentDashboardModel(
      totalBrokers: json['total_brokers'] ?? 0,
      activeBrokers: json['active_brokers'] ?? 0,
      pendingVerification: json['pending_verification'] ?? 0,
      suspendedActionReq: json['suspended_action_req'] ?? 0,
      topRecruiters: (json['top_recruiters'] as List<dynamic>?)
          ?.map((e) => RecruiterModel.fromJson(e))
          .toList() ?? [],
    );
  }
}

// Model for the Advisor who recruits others
class RecruiterModel {
  final String id;
  final String name;
  final String joinedDate;
  final int recruitCount;
  final String initials;

  RecruiterModel({
    required this.id, required this.name, required this.joinedDate,
    required this.recruitCount, required this.initials,
  });

  factory RecruiterModel.fromJson(Map<String, dynamic> json) => RecruiterModel(
    id: json['id']?.toString() ?? '', name: json['name'] ?? '',
    joinedDate: json['joined_date'] ?? '', recruitCount: json['recruit_count'] ?? 0,
    initials: json['initials'] ?? '',
  );
}

// Model for the specific people an advisor has recruited
class RecruitedPersonModel {
  final String id;
  final String name;
  final String joinedDate;
  final String status; // 'Active', 'Pending', 'Suspended'
  final String initials;

  RecruitedPersonModel({
    required this.id, required this.name, required this.joinedDate,
    required this.status, required this.initials,
  });

  factory RecruitedPersonModel.fromJson(Map<String, dynamic> json) => RecruitedPersonModel(
    id: json['id']?.toString() ?? '', name: json['name'] ?? '',
    joinedDate: json['joined_date'] ?? '', status: json['status'] ?? 'Pending',
    initials: json['initials'] ?? '',
  );
}