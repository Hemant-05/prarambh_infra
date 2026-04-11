import '../../../../data/datasources/remote/api_client.dart';
import '../models/team_models.dart';

class AdminTeamRepository {
  final ApiClient apiClient;
  AdminTeamRepository({required this.apiClient});

  Future<BrokerProfileModel> getBrokerProfile(String advisorId) async {
    try {
      // /advisor/profile/{id} returns the FULL nested profile with all sections
      final response = await apiClient.getAdvisorProfile(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return BrokerProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<BrokerProfileModel> getBrokerProfileByCode(String code) async {
    try {
      final response = await apiClient.getAdvisorByCode(code);
      if (response['status'] == true || response['status'] == 'success') {
        return BrokerProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor by code');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateAdvisorStatus(String advisorId, String status, String reason) async {
    try {
      final response = await apiClient.changeAdvisorStatus(advisorId, {
        'status': status,
        'reason': reason,
      });
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateAdvisorType(String advisorId, String advisorType) async {
    try {
      final response = await apiClient.updateAdvisorType(advisorId, advisorType);
      return response['status'] == true || response['status'] == 'success';
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