import '../../../../data/datasources/remote/api_client.dart';
import '../models/team_models.dart';

class AdminTeamRepository {
  final ApiClient apiClient;
  AdminTeamRepository({required this.apiClient});

  Future<AdvisorNode> getTeamHierarchy() async {
    try {
      final response = await apiClient.getTeamHierarchy();
      if (response['status'] == 'success') return AdvisorNode.fromJson(response['data']);
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<BrokerProfileModel> getBrokerProfile(String id) async {
    try {
      final response = await apiClient.getBrokerProfile(id);
      if (response['status'] == 'success') return BrokerProfileModel.fromJson(response['data']);
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }
}