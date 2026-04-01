import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_profile_model.dart';

class AdminProfileRepository {
  final ApiClient apiClient;

  AdminProfileRepository({required this.apiClient});

  Future<AdminProfileModel> getProfile(String userId) async {
    try {
      final response = await apiClient.getAdvisorProfile(userId);
      // Safely check status
      if (response['status'] == true || response['status'] == 'success') {
        return AdminProfileModel.fromJson(response['data']['advisor_details']);
      }
      throw Exception(response['message'] ?? 'Failed to load profile');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.updateAdvisor(userId, data);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await apiClient.deleteAdvisor(userId);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}