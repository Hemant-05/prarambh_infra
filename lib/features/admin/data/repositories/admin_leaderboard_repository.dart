import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_rank_model.dart';

class AdminLeaderboardRepository {
  final ApiClient apiClient;

  AdminLeaderboardRepository({required this.apiClient});

  Future<List<AdvisorRankModel>> getLeaderboard() async {
    try {
      final response = await apiClient.getLeaderboard();
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AdvisorRankModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load leaderboard');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> evaluateLevel(String advisorId) async {
    try {
      final response = await apiClient.evaluateLevel(advisorId);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}