class AdminDashboardModel {
  final int unitsSold;
  final int unitsTarget;
  final int monthlyProgressPercent;
  final int suspectingLeads;
  final int prospectingLeads;
  final int siteVisitingLeads;
  final int bookingLeads;
  final int referralLeads;
  final int completedLeads;
  final String? projectName;
  final List<dynamic> priorityLeads;
  final List<dynamic> pendingVerifications;
  final List<dynamic> recentClosures;
  final int totalPendingTasks;
  final List<PendingAction> pendingActions;

  AdminDashboardModel({
    required this.unitsSold,
    required this.unitsTarget,
    required this.monthlyProgressPercent,
    required this.suspectingLeads,
    required this.prospectingLeads,
    required this.siteVisitingLeads,
    required this.bookingLeads,
    required this.referralLeads,
    required this.completedLeads,
    this.projectName,
    required this.priorityLeads,
    required this.pendingVerifications,
    required this.recentClosures,
    required this.totalPendingTasks,
    required this.pendingActions,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final up = json['units_progress'] ?? {};
    final so = json['sales_overview'] ?? {};
    final pa = json['pending_actions'] ?? {};

    List<PendingAction> actions = [];
    if (pa['tasks'] is List) {
      actions = (pa['tasks'] as List)
          .map((item) => PendingAction.fromJson(item))
          .toList();
    }

    return AdminDashboardModel(
      unitsSold: int.tryParse(up['sold']?.toString() ?? '0') ?? 0,
      unitsTarget: int.tryParse(up['total']?.toString() ?? '0') ?? 0,
      monthlyProgressPercent: int.tryParse(up['monthly_progress']?.toString() ?? '0') ?? 0,
      suspectingLeads: int.tryParse(so['suspecting']?.toString() ?? '0') ?? 0,
      prospectingLeads: int.tryParse(so['prospecting']?.toString() ?? '0') ?? 0,
      siteVisitingLeads: int.tryParse(so['site_visiting']?.toString() ?? '0') ?? 0,
      bookingLeads: int.tryParse(so['booking']?.toString() ?? '0') ?? 0,
      referralLeads: int.tryParse(so['referral']?.toString() ?? '0') ?? 0,
      completedLeads: int.tryParse(so['completed']?.toString() ?? '0') ?? 0,
      projectName: up['project_name']?.toString(),
      priorityLeads: json['priority_leads'] is List ? json['priority_leads'] : [],
      pendingVerifications: json['pending_verifications'] is List ? json['pending_verifications'] : [],
      recentClosures: json['recent_deal_closures'] is List ? json['recent_deal_closures'] : [],
      totalPendingTasks: int.tryParse(pa['total_tasks']?.toString() ?? '0') ?? 0,
      pendingActions: actions,
    );
  }
}

class PendingAction {
  final String iconType;
  final String title;
  final String description;

  PendingAction({
    required this.iconType,
    required this.title,
    required this.description,
  });

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      iconType: json['icon_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}