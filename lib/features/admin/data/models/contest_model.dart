import 'dart:convert';

class ContestModel {
  final String id;
  final String title;
  final String status;
  final String rewardText;
  final String targetText;
  final String dateRange;
  final String imageUrl;
  final String? startDate;
  final String? endDate;
  final List<TopPerformer>? topPerformers;
  final List<String>? rules;
  final List<ContestParticipant> participants;

  ContestModel({
    required this.id, required this.title, required this.status,
    required this.rewardText, required this.targetText, required this.dateRange,
    required this.imageUrl, this.startDate, this.endDate, this.topPerformers, this.rules,
    required this.participants,
  });

  // Accurate Time-Based Getters
  static DateTime? _smartParse(String? dateStr) {
    if (dateStr == null) return null;
    // Try standard YYYY-MM-DD
    DateTime? parsed = DateTime.tryParse(dateStr);
    if (parsed != null) return parsed;

    // Try DD-MM-YYYY
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        if (parts[0].length == 4) return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}
    return null;
  }

  bool get isUpcoming {
    final start = _smartParse(startDate);
    if (start == null) return false;
    return DateTime.now().isBefore(start);
  }

  bool get isLive {
    final now = DateTime.now();
    final start = _smartParse(startDate);
    final end = _smartParse(endDate);
    if (start == null || end == null) return false;
    // End of day buffer (23:59:59)
    final endOfDay = end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    return now.isAfter(start) && now.isBefore(endOfDay);
  }

  bool get isEnded {
    final end = _smartParse(endDate);
    if (end == null) return false;
    // End of day buffer (23:59:59)
    final endOfDay = end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    return DateTime.now().isAfter(endOfDay);
  }

  int get daysLeft {
    final end = _smartParse(endDate);
    if (end == null) return 0;
    final diff = end.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://workiees.com/";

    // Safely parse image URL
    String rawUrl = json['reward_image'] ?? json['image_url'] ?? '';
    String finalImageUrl = rawUrl.startsWith('http')
        ? rawUrl
        : (rawUrl.isNotEmpty ? baseUrl + (rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl) : '');

    // Safely parse rules
    List<String> parsedRules = [];
    if (json['rules'] is List) {
      for (var rule in json['rules']) {
        String ruleStr = rule.toString();
        if (ruleStr.startsWith('[') && ruleStr.endsWith(']')) {
          try {
            List decoded = jsonDecode(ruleStr);
            parsedRules.addAll(decoded.map((e) => e.toString()));
          } catch (_) {
            parsedRules.add(ruleStr);
          }
        } else {
          parsedRules.add(ruleStr);
        }
      }
    }

    return ContestModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'Active',
      rewardText: json['reward_name'] ?? json['reward_text'] ?? '',
      targetText: 'Achieve Target',
      dateRange: "${json['start_date'] ?? ''} - ${json['end_date'] ?? ''}",
      imageUrl: finalImageUrl,
      startDate: json['start_date'],
      endDate: json['end_date'],
      rules: parsedRules,
      participants: (json['participants'] as List<dynamic>?)?.map((e) => ContestParticipant.fromJson(e)).toList() ?? [],
      topPerformers: (json['top_performers'] as List<dynamic>?)?.map((e) => TopPerformer.fromJson(e)).toList(),
    );
  }
}

class ContestParticipant {
  final String advisorCode;
  final double selling;
  final int units;

  ContestParticipant({required this.advisorCode, required this.selling, required this.units});

  factory ContestParticipant.fromJson(Map<String, dynamic> json) {
    return ContestParticipant(
      advisorCode: json['advisor_code'] ?? '',
      selling: double.tryParse(json['selling']?.toString() ?? '0') ?? 0.0,
      units: int.tryParse(json['units']?.toString() ?? '0') ?? 0,
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
    id: json['id']?.toString() ?? '', name: json['name'] ?? '', location: json['location'] ?? '', units: json['units']?.toString() ?? '0', initials: json['initials'] ?? '',
  );
}