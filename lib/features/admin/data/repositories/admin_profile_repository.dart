import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_profile_model.dart';

class AdminProfileRepository {
  final ApiClient apiClient;

  AdminProfileRepository({required this.apiClient});

  Future<AdminProfileModel> getProfile(String userId) async {
    try {
      final response = await apiClient.getSingleUser(userId);
      if (response['status']) {
        return AdminProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load profile');
    } catch (e) { rethrow; }
  }

  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.updateUserProfile(userId, data);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await apiClient.deleteUser(userId);
      return response['status'];
    } catch (e) { rethrow; }
  }
}