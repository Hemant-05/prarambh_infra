import '../../../../data/datasources/remote/api_client.dart';
import '../models/recruitment_model.dart';

class AdminRecruitmentRepository {
  final ApiClient apiClient;

  AdminRecruitmentRepository({required this.apiClient});

  /// Fetch all advisors as the recruitment pipeline.
  /// The new ApiClient does not have a dedicated recruitment dashboard endpoint.
  /// Use getAllAdvisors from AdminAdvisorRepository or the leaderboard for summary data.
  Future<List<RecruitedPersonModel>> getRecruitsByAdvisor(String advisorId) async {
    try {
      // The new ApiClient does not expose a recruits-by-advisor endpoint.
      // Fetching the advisor's full record as a fallback.
      final response = await apiClient.getSingleAdvisor(advisorId);
      if (response['status']) {
        final data = response['data'];
        // Wrap single advisor data as a list entry.
        return [RecruitedPersonModel.fromJson(data)];
      }
      throw Exception(response['message'] ?? 'Failed to load recruits');
    } catch (e) {
      rethrow;
    }
  }

  /// NOTE: There is no dedicated recruitment dashboard endpoint in the new ApiClient.
  /// Use AdminAdvisorRepository.getAllAdvisors() + AdminLeaderboardRepository.getLeaderboard()
  /// to compose dashboard-level data.
  Future<RecruitmentDashboardModel> getDashboard() async {
    throw UnimplementedError(
      'No dedicated recruitment dashboard endpoint exists in the new ApiClient. '
      'Compose from getAllAdvisors() and getLeaderboard().',
    );
  }
}