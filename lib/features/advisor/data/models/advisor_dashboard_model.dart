class AdvisorDashboardModel {
  final String name;
  final String role;
  final String advisorId;
  final String parentName;
  final String currentLevel;
  final String nextLevel;
  final int progressPercent;

  final SalesConversion sales;
  final List<PendingAction> pendingActions;
  final List<PromotionMetric> promotionStatus;
  final List<ActiveContest> activeContests;

  AdvisorDashboardModel({
    required this.name, required this.role, required this.advisorId,
    required this.parentName, required this.currentLevel, required this.nextLevel,
    required this.progressPercent, required this.sales, required this.pendingActions,
    required this.promotionStatus, required this.activeContests,
  });

  factory AdvisorDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdvisorDashboardModel(
      name: json['name'] ?? 'Unknown Advisor',
      role: json['role'] ?? 'Advisor',
      advisorId: json['advisor_id'] ?? '',
      parentName: json['parent_name'] ?? 'None',
      currentLevel: json['current_level'] ?? '',
      nextLevel: json['next_level'] ?? '',
      progressPercent: json['progress_percent'] ?? 0,
      sales: SalesConversion.fromJson(json['sales'] ?? {}),
      pendingActions: (json['pending_actions'] as List?)?.map((e) => PendingAction.fromJson(e)).toList() ?? [],
      promotionStatus: (json['promotion_status'] as List?)?.map((e) => PromotionMetric.fromJson(e)).toList() ?? [],
      activeContests: (json['active_contests'] as List?)?.map((e) => ActiveContest.fromJson(e)).toList() ?? [],
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
      suspecting: json['suspecting'] ?? 0,
      prospecting: json['prospecting'] ?? 0,
      siteVisit: json['site_visit'] ?? 0,
    );
  }
}

class PendingAction {
  final String title;
  final String subtitle;
  final String time;

  PendingAction({required this.title, required this.subtitle, required this.time});

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(title: json['title'] ?? '', subtitle: json['subtitle'] ?? '', time: json['time'] ?? '');
  }
}

class PromotionMetric {
  final String metric;
  final String target;
  final String achieved;

  PromotionMetric({required this.metric, required this.target, required this.achieved});

  factory PromotionMetric.fromJson(Map<String, dynamic> json) {
    return PromotionMetric(metric: json['metric'] ?? '', target: json['target'] ?? '', achieved: json['achieved'] ?? '');
  }
}

class ActiveContest {
  final String title;
  final String? subtitle;

  ActiveContest({required this.title, this.subtitle});

  factory ActiveContest.fromJson(Map<String, dynamic> json) {
    return ActiveContest(title: json['title'] ?? '', subtitle: json['subtitle']);
  }
}