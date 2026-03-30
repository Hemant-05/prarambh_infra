import '../../../../data/datasources/remote/api_client.dart';

class AdminRecruitmentRepository {
  final ApiClient apiClient;

  AdminRecruitmentRepository({required this.apiClient});

  Future<dynamic> getTeamTree({String? leaderId}) async {
    try {
      final response = await apiClient.getTeamTree(leaderId);
      if (response['status']) {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to load team tree');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getDashboard({String? leaderId}) async {
    try {
      final response = await apiClient.getRecruitmentDashboard(leaderId);
      if (response['status']) {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to load dashboard');
    } catch (e) {
      rethrow;
    }
  }
}
