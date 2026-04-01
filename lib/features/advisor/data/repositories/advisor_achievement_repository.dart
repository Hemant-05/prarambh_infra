import '../../../../data/datasources/remote/api_client.dart';
import '../models/achievement_model.dart';
import 'package:flutter/foundation.dart';

class AdvisorAchievementRepository {
  final ApiClient apiClient;

  AdvisorAchievementRepository({required this.apiClient});

  Future<List<AchievementModel>> getAchievements(String advisorCode) async {
    try {
      final response = await apiClient.getAdvisorAchievements(advisorCode);
      if (response != null && response['status'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => AchievementModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get Achievements Error: $e');
      throw Exception('Failed to fetch achievements');
    }
  }
}
