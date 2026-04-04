import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_team_model.dart';
import '../models/advisor_performance_model.dart';
import '../models/team_activity_model.dart';

class AdvisorTeamRepository {
  final ApiClient apiClient;

  AdvisorTeamRepository({required this.apiClient});

  Future<AdvisorTeamNode> getTeamTree(String leaderId) async {
    try {
      final response = await apiClient.getTeamTree(leaderId);
      if (response['status'] == true || response['status'] == 'success') {
        final data = response['data'];

        if (data is List && data.isNotEmpty) {
          return AdvisorTeamNode.fromJson(data.first as Map<String, dynamic>);
        } else if (data is Map<String, dynamic>) {
          return AdvisorTeamNode.fromJson(data);
        } else {
          throw Exception('Invalid data format received from API');
        }
      }
      throw Exception(response['message'] ?? 'Failed to load team tree');
    } catch (e) {
      rethrow;
    }
  }

  Future<AdvisorPerformanceModel> getAdvisorPerformance(String advisorId) async {
    try {
      final response = await apiClient.getAdvisorTeam(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return AdvisorPerformanceModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor performance');
    } catch (e) {
      rethrow;
    }
  }

  Future<TeamActivityModel> getTeamActivity(String advisorCode, {int? month, int? year}) async {
    try {
      final response = await apiClient.getTeamActivity(advisorCode, month, year);
      if (response['status'] == true || response['status'] == 'success') {
        return TeamActivityModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load team activity');
    } catch (e) {
      rethrow;
    }
  }
}