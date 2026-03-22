class AdminDashboardModel {
  final int unitsSold;
  final int unitsTarget;
  final int monthlyProgressPercent;
  final int suspectingLeads;
  final int prospectingLeads;
  final int siteVisitingLeads;
  final int bookingLeads;
  final int referralLeads;
  // Note: Add Lists here later for 'pending_verifications' and 'recent_closures'
  // depending on how your PHP backend sends those arrays.

  AdminDashboardModel({
    required this.unitsSold,
    required this.unitsTarget,
    required this.monthlyProgressPercent,
    required this.suspectingLeads,
    required this.prospectingLeads,
    required this.siteVisitingLeads,
    required this.bookingLeads,
    required this.referralLeads,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    // Note: Adjust these keys ('units_sold', etc.) to match exactly what your PHP dev returns.
    return AdminDashboardModel(
      unitsSold: json['units_sold'] ?? 0,
      unitsTarget: json['units_target'] ?? 150, // Defaulting to 150 based on your UI
      monthlyProgressPercent: json['monthly_progress'] ?? 0,
      suspectingLeads: json['sales_overview']?['suspecting'] ?? 0,
      prospectingLeads: json['sales_overview']?['prospecting'] ?? 0,
      siteVisitingLeads: json['sales_overview']?['site_visiting'] ?? 0,
      bookingLeads: json['sales_overview']?['booking'] ?? 0,
      referralLeads: json['sales_overview']?['referral'] ?? 0,
    );
  }
}