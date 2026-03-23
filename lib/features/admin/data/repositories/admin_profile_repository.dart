import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_profile_model.dart';

class AdminProfileRepository {
  final ApiClient apiClient;

  AdminProfileRepository({required this.apiClient});

  Future<AdminProfileModel> getProfile() async {
    try {
      final response = await apiClient.getAdminProfile();
      if (response['status'] == 'success') {
        return AdminProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load profile');
    } catch (e) { rethrow; }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.updateAdminProfile(data);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await apiClient.changeAdminPassword({
        "old_password": oldPassword,
        "new_password": newPassword,
      });
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}