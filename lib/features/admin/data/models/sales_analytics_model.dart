class SalesAnalyticsModel {
  final SalesSummary summary;
  final List<MonthlyChartData> barChartMonthly;
  final List<ProjectChartData> pieChartProjects;
  final List<FunnelStageData> funnelChartLeads;
  final List<AdvisorPerformanceData> topAdvisors;

  SalesAnalyticsModel({
    required this.summary,
    required this.barChartMonthly,
    required this.pieChartProjects,
    required this.funnelChartLeads,
    required this.topAdvisors,
  });

  factory SalesAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SalesAnalyticsModel(
      summary: SalesSummary.fromJson(json['summary'] ?? {}),
      barChartMonthly: (json['bar_chart_monthly'] as List? ?? [])
          .map((e) => MonthlyChartData.fromJson(e))
          .toList(),
      pieChartProjects: (json['pie_chart_projects'] as List? ?? [])
          .map((e) => ProjectChartData.fromJson(e))
          .toList(),
      funnelChartLeads: (json['funnel_chart_leads'] as List? ?? [])
          .map((e) => FunnelStageData.fromJson(e))
          .where((e) => e.stage.toLowerCase() != 'new') // User requested to filter out 'new'
          .toList(),
      topAdvisors: (json['top_advisors'] as List? ?? [])
          .map((e) => AdvisorPerformanceData.fromJson(e))
          .toList(),
    );
  }
}

class SalesSummary {
  final int totalDeals;
  final double totalRevenue;
  final int totalActiveAdvisors;
  final int totalSiteVisits;

  SalesSummary({
    required this.totalDeals,
    required this.totalRevenue,
    required this.totalActiveAdvisors,
    required this.totalSiteVisits,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalDeals: json['total_deals'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalActiveAdvisors: json['total_active_advisors'] ?? 0,
      totalSiteVisits: json['total_site_visits'] ?? 0,
    );
  }
}

class MonthlyChartData {
  final String month;
  final int totalDeals;
  final double totalRevenue;

  MonthlyChartData({
    required this.month,
    required this.totalDeals,
    required this.totalRevenue,
  });

  factory MonthlyChartData.fromJson(Map<String, dynamic> json) {
    return MonthlyChartData(
      month: json['month'] ?? '',
      totalDeals: json['total_deals'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}

class ProjectChartData {
  final String projectName;
  final int dealsCount;
  final double totalRevenue;

  ProjectChartData({
    required this.projectName,
    required this.dealsCount,
    required this.totalRevenue,
  });

  factory ProjectChartData.fromJson(Map<String, dynamic> json) {
    return ProjectChartData(
      projectName: json['project_name'] ?? '',
      dealsCount: json['deals_count'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}

class FunnelStageData {
  final String stage;
  final int count;

  FunnelStageData({required this.stage, required this.count});

  factory FunnelStageData.fromJson(Map<String, dynamic> json) {
    return FunnelStageData(
      stage: json['stage'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  // Helper for display labels
  String get displayLabel {
    switch (stage.toLowerCase()) {
      case 'pending_verification': return 'PENDING APPROVAL';
      case 'sus suspecting':
      case 'suspecting': return 'SUSPECTING';
      case 'prospecting': return 'PROSPECTING';
      case 'site visit': return 'SITE VISITS';
      case 'booking': return 'BOOKING DONE';
      case 'completed': return 'SALES COMPLETED';
      default: return stage.toUpperCase();
    }
  }
}

class AdvisorPerformanceData {
  final String advisorCode;
  final String fullName;
  final String? profilePhoto;
  final int totalDeals;
  final double totalRevenue;

  AdvisorPerformanceData({
    required this.advisorCode,
    required this.fullName,
    this.profilePhoto,
    required this.totalDeals,
    required this.totalRevenue,
  });

  factory AdvisorPerformanceData.fromJson(Map<String, dynamic> json) {
    return AdvisorPerformanceData(
      advisorCode: json['Advisor_code'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePhoto: json['profile_photo'],
      totalDeals: json['total_deals'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}
