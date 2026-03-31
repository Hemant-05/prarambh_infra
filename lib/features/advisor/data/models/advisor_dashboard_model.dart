class AdvisorDashboardModel {
  final String name;
  final String role;
  final String advisorId;
  final String parentName;
  final String profilePhoto;
  final String status;

  final String currentLevel;
  final String nextLevel;
  final int progressPercent;

  final SalesConversion sales;
  final List<PendingAction> pendingActions;
  final List<PromotionMetric> promotionStatus;
  final List<ActiveContest> activeContests;

  AdvisorDashboardModel({
    required this.name, required this.role, required this.advisorId,
    required this.parentName, required this.profilePhoto, required this.status,
    required this.currentLevel, required this.nextLevel, required this.progressPercent,
    required this.sales, required this.pendingActions, required this.promotionStatus,
    required this.activeContests,
  });

  factory AdvisorDashboardModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};
    final career = json['career_progress'] ?? {};
    final pending = json['pending_actions'] ?? {};

    const String baseUrl = "https://workiees.com/";
    String rawPhoto = profile['profile_photo']?.toString() ?? '';
    String finalPhoto = rawPhoto.startsWith('http')
        ? rawPhoto
        : (rawPhoto.isNotEmpty ? baseUrl + (rawPhoto.startsWith('/') ? rawPhoto.substring(1) : rawPhoto) : '');

    return AdvisorDashboardModel(
      name: profile['name']?.toString() ?? 'Unknown',
      role: profile['designation']?.toString() ?? 'Advisor',
      advisorId: profile['id']?.toString() ?? '',
      parentName: profile['parent_name']?.toString() ?? 'N/A',
      status: profile['status']?.toString() ?? 'ACTIVE',
      profilePhoto: finalPhoto,

      currentLevel: career['current_level']?.toString() ?? 'Advisor',
      nextLevel: career['next_level']?.toString() ?? 'Director',
      progressPercent: int.tryParse(career['progress_percentage']?.toString() ?? '0') ?? 0,

      sales: SalesConversion.fromJson(json['sales_conversion'] ?? {}),
      pendingActions: (pending['tasks'] as List<dynamic>?)?.map((e) => PendingAction.fromJson(e)).toList() ?? [],
      promotionStatus: (json['promotion_status'] as List<dynamic>?)?.map((e) => PromotionMetric.fromJson(e)).toList() ?? [],
      activeContests: (json['active_contests'] as List<dynamic>?)?.map((e) => ActiveContest.fromJson(e)).toList() ?? [],
    );
  }
}

class SalesConversion {
  final int suspecting;
  final int prospecting;
  final int siteVisit;

  SalesConversion({required this.suspecting, required this.prospecting, required this.siteVisit});

  factory SalesConversion.fromJson(Map<String, dynamic> json) {
    return SalesConversion(
      suspecting: int.tryParse(json['suspecting']?.toString() ?? '0') ?? 0,
      prospecting: int.tryParse(json['prospecting']?.toString() ?? '0') ?? 0,
      siteVisit: int.tryParse(json['site_visit']?.toString() ?? '0') ?? 0,
    );
  }
}

class PendingAction {
  final String iconType;
  final String title;
  final String subtitle;
  final String time;

  PendingAction({required this.iconType, required this.title, required this.subtitle, required this.time});

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      iconType: json['icon_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['description']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

class PromotionMetric {
  final String metric;
  final String target;
  final String achieved;

  PromotionMetric({required this.metric, required this.target, required this.achieved});

  factory PromotionMetric.fromJson(Map<String, dynamic> json) {
    return PromotionMetric(
      metric: json['metric']?.toString() ?? '',
      target: json['target']?.toString() ?? '0',
      achieved: json['achieved']?.toString() ?? '0',
    );
  }
}

class ActiveContest {
  final String title;
  final String? subtitle;

  ActiveContest({required this.title, this.subtitle});

  factory ActiveContest.fromJson(Map<String, dynamic> json) {
    return ActiveContest(
      title: json['title']?.toString() ?? '',
      subtitle: json['reward_name']?.toString(),
    );
  }
}