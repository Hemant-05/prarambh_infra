import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_dashboard_model.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({required this.apiClient});

  Future<AdminDashboardModel> getDashboardData(int userId) async {
    try {
      final response = await apiClient.getDashboardData(userId, "Admin");
      if (response['status'] == 'success') {
        return AdminDashboardModel.fromJson(response['data'] ?? response);
      }
      throw Exception(response['message'] ?? 'Failed to load dashboard data');
    } catch (e) {
      rethrow;
    }
  }
}