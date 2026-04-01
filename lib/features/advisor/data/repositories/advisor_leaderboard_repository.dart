import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_leaderboard_model.dart';

class AdvisorLeaderboardRepository {
  final ApiClient apiClient;

  AdvisorLeaderboardRepository({required this.apiClient});

  Future<List<AdvisorLeaderboardModel>> getLeaderboard({int? month, int? year}) async {
    try {
      final response = await apiClient.getLeaderboard(month, year);
      final status = response['status'];
      if (status == true || status == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AdvisorLeaderboardModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load leaderboard');
    } catch (e) {
      rethrow;
    }
  }
}
