class AdvisorRankModel {
  final String id;
  final String name;
  final String avatarUrl; // We will use this later when you have real images
  final int rank;
  final String primaryValue; // e.g., "₹2.5L"
  final String secondaryValue; // e.g., "15 Deals"
  final String trend; // e.g., "12%"
  final bool isTrendPositive;
  final double progress; // 0.0 to 1.0 for the bar

  AdvisorRankModel({
    required this.id, required this.name, required this.avatarUrl,
    required this.rank, required this.primaryValue, required this.secondaryValue,
    required this.trend, required this.isTrendPositive, required this.progress,
  });

  factory AdvisorRankModel.fromJson(Map<String, dynamic> json) {
    return AdvisorRankModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      rank: json['rank'] ?? 0,
      primaryValue: json['primary_value'] ?? '',
      secondaryValue: json['secondary_value'] ?? '',
      trend: json['trend'] ?? '0%',
      isTrendPositive: json['is_trend_positive'] ?? true,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }
}