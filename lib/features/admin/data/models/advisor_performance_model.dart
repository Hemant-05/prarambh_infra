import 'team_models.dart';

class AdvisorPerformanceModel {
  final LeaderInfo leaderInfo;
  final CareerProgress careerProgress;
  final RecruitmentStats recruitmentStats;
  final List<TeamMemberModel> teamMembers;

  AdvisorPerformanceModel({
    required this.leaderInfo,
    required this.careerProgress,
    required this.recruitmentStats,
    required this.teamMembers,
  });

  factory AdvisorPerformanceModel.fromJson(Map<String, dynamic> json) {
    return AdvisorPerformanceModel(
      leaderInfo: LeaderInfo.fromJson(json['leader_info'] ?? {}),
      careerProgress: CareerProgress.fromJson(json['career_progress'] ?? {}),
      recruitmentStats: RecruitmentStats.fromJson(json['recruitment_stats'] ?? {}),
      teamMembers: (json['team_members'] as List? ?? [])
          .map((e) => TeamMemberModel.fromJson(e))
          .toList(),
    );
  }
}

class LeaderInfo {
  final int id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String profilePhoto;
  final String status;

  LeaderInfo({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.designation,
    required this.profilePhoto,
    required this.status,
  });

  factory LeaderInfo.fromJson(Map<String, dynamic> json) {
    return LeaderInfo(
      id: json['id'] ?? 0,
      advisorCode: json['Advisor_code'] ?? '',
      fullName: json['full_name'] ?? '',
      designation: json['designation'] ?? '',
      profilePhoto: json['profile_photo'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class CareerProgress {
  final String currentLevel;
  final String nextLevel;
  final int overallProgressPercentage;
  final List<PerformanceMetric> metrics;

  CareerProgress({
    required this.currentLevel,
    required this.nextLevel,
    required this.overallProgressPercentage,
    required this.metrics,
  });

  factory CareerProgress.fromJson(Map<String, dynamic> json) {
    return CareerProgress(
      currentLevel: json['current_level'] ?? '',
      nextLevel: json['next_level'] ?? '',
      overallProgressPercentage: json['overall_progress_percentage'] ?? 0,
      metrics: (json['metrics'] as List? ?? [])
          .map((e) => PerformanceMetric.fromJson(e))
          .toList(),
    );
  }
}

class PerformanceMetric {
  final String metric;
  final num target;
  final num achieved;
  final int percentage;

  PerformanceMetric({
    required this.metric,
    required this.target,
    required this.achieved,
    required this.percentage,
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      metric: json['metric'] ?? '',
      target: json['target'] ?? 0,
      achieved: json['achieved'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

class RecruitmentStats {
  final int totalRecruits;
  final int activeRecruits;
  final int pendingRecruits;
  final int inactiveRecruits;

  RecruitmentStats({
    required this.totalRecruits,
    required this.activeRecruits,
    required this.pendingRecruits,
    required this.inactiveRecruits,
  });

  factory RecruitmentStats.fromJson(Map<String, dynamic> json) {
    return RecruitmentStats(
      totalRecruits: json['total_recruits'] ?? 0,
      activeRecruits: json['active_recruits'] ?? 0,
      pendingRecruits: json['pending_recruits'] ?? 0,
      inactiveRecruits: json['inactive_recruits'] ?? 0,
    );
  }
}
