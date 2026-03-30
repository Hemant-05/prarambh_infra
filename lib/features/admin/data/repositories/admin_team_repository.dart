import '../../../../data/datasources/remote/api_client.dart';
import '../models/team_models.dart';

class AdminTeamRepository {
  final ApiClient apiClient;
  AdminTeamRepository({required this.apiClient});

  Future<BrokerProfileModel> getBrokerProfile(String advisorId) async {
    try {
      final response = await apiClient.getSingleAdvisor(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return BrokerProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<List<dynamic>> getAllAdvisors() async {
    try {
      final response = await apiClient.getAllAdvisors('');
      if (response['status'] == true || response['status'] == 'success') {
        return response['data'] ?? [];
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<dynamic> getTeamHierarchy({String? leaderId}) async {
    try {
      final response = await apiClient.getTeamTree(leaderId);
      if (response['status'] == true || response['status'] == 'success') {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to load team tree');
    } catch (e) { rethrow; }
  }
}