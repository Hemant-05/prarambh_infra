class AdminDashboardModel {
  final int unitsSold;
  final int unitsTarget;
  final int monthlyProgressPercent;
  final int suspectingLeads;
  final int prospectingLeads;
  final int siteVisitingLeads;
  final int bookingLeads;
  final int referralLeads;
  final List<dynamic> pendingVerifications;
  final List<dynamic> recentClosures;

  AdminDashboardModel({
    required this.unitsSold,
    required this.unitsTarget,
    required this.monthlyProgressPercent,
    required this.suspectingLeads,
    required this.prospectingLeads,
    required this.siteVisitingLeads,
    required this.bookingLeads,
    required this.referralLeads,
    required this.pendingVerifications,
    required this.recentClosures,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      unitsSold: json['units_sold'] ?? 0,
      unitsTarget: json['units_target'] ?? 150,
      monthlyProgressPercent: json['monthly_progress'] ?? 0,
      suspectingLeads: json['sales_overview']?['suspecting'] ?? 0,
      prospectingLeads: json['sales_overview']?['prospecting'] ?? 0,
      siteVisitingLeads: json['sales_overview']?['site_visiting'] ?? 0,
      bookingLeads: json['sales_overview']?['booking'] ?? 0,
      referralLeads: json['sales_overview']?['referral'] ?? 0,
      pendingVerifications: json['pending_verifications'] ?? [],
      recentClosures: json['recent_closures'] ?? [],
    );
  }
}