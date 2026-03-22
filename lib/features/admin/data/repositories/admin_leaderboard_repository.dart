import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_rank_model.dart';

class AdminLeaderboardRepository {
  final ApiClient apiClient;

  AdminLeaderboardRepository({required this.apiClient});

  Future<List<AdvisorRankModel>> getLeaderboard(String type) async {
    try {
      final response = await apiClient.getLeaderboard(type);
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AdvisorRankModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load leaderboard');
    } catch (e) {
      rethrow;
    }
  }
}