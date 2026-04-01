import 'package:flutter/material.dart';

class AchievementModel {
  final int id;
  final int advisorId;
  final String title;
  final String type; // Award, Trophy, Milestone, etc.
  final String description;
  final String timeOfAchievement; // e.g. "2024-03-31 14:00:00"
  final String advisorCode;
  final String fullName;
  final String createdAt;

  AchievementModel({
    required this.id,
    required this.advisorId,
    required this.title,
    required this.type,
    required this.description,
    required this.timeOfAchievement,
    required this.advisorCode,
    required this.fullName,
    required this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? 0,
      advisorId: json['advisor_id'] is int ? json['advisor_id'] : int.tryParse(json['advisor_id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? 'Achievement',
      type: json['type'] ?? 'Award',
      description: json['description'] ?? '',
      timeOfAchievement: json['time_of_achievement'] ?? '',
      advisorCode: json['Advisor_code'] ?? '',
      fullName: json['full_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  // Helpers for UI
  String get year => timeOfAchievement.split('-')[0];
  
  String get formattedDate {
    if (timeOfAchievement.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(timeOfAchievement);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
    } catch (e) {
      return timeOfAchievement;
    }
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'award':
        return Icons.emoji_events_outlined;
      case 'contest':
      case 'competition':
        return Icons.military_tech_outlined;
      case 'joined':
      case 'milestone':
        return Icons.rocket_launch_outlined;
      case 'sale':
        return Icons.handshake_outlined;
      default:
        return Icons.star_outline_rounded;
    }
  }

  Color get color {
    switch (type.toLowerCase()) {
      case 'award':
        return Colors.blue;
      case 'contest':
        return Colors.green;
      case 'joined':
        return Icons.rocket_launch_outlined as Color? ?? Colors.purple;
      case 'sale':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
