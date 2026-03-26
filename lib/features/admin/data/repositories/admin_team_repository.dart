import '../../../../data/datasources/remote/api_client.dart';
import '../models/team_models.dart';

class AdminTeamRepository {
  final ApiClient apiClient;
  AdminTeamRepository({required this.apiClient});

  Future<AdvisorNode> getTeamHierarchy(int adminId) async {
    try {
      final response = await apiClient.getTeamHierarchy(adminId, "tree");
      if (response['status'] == 'success') return AdvisorNode.fromJson(response['data']);
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<BrokerProfileModel> getBrokerProfile(int advisorId) async {
    try {
      final response = await apiClient.getProfile(advisorId);
      if (response['status'] == 'success') return BrokerProfileModel.fromJson(response['data']);
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }
}