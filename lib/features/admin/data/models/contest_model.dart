class ContestModel {
  final String id;
  final String title;
  final String status; // 'LIVE', 'UPCOMING', 'COMPLETED'
  final String rewardText;
  final String targetText;
  final String dateRange;
  final String imageUrl;
  final String? endDate;
  final List<TopPerformer>? topPerformers;
  final List<String>? rules;

  ContestModel({
    required this.id, required this.title, required this.status,
    required this.rewardText, required this.targetText, required this.dateRange,
    required this.imageUrl, this.endDate, this.topPerformers, this.rules,
  });

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    return ContestModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'LIVE',
      rewardText: json['reward_text'] ?? '',
      targetText: json['target_text'] ?? '',
      dateRange: json['date_range'] ?? '',
      imageUrl: json['image_url'] ?? '',
      endDate: json['end_date'],
      rules: (json['rules'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      topPerformers: (json['top_performers'] as List<dynamic>?)?.map((e) => TopPerformer.fromJson(e)).toList(),
    );
  }
}

class TopPerformer {
  final String id;
  final String name;
  final String location;
  final String units;
  final String initials;

  TopPerformer({required this.id, required this.name, required this.location, required this.units, required this.initials});

  factory TopPerformer.fromJson(Map<String, dynamic> json) => TopPerformer(
    id: json['id']?.toString() ?? '', name: json['name'] ?? '', location: json['location'] ?? '', units: json['units'] ?? '', initials: json['initials'] ?? '',
  );
}