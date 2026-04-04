import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_dashboard_model.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({required this.apiClient});

  Future<AdminDashboardModel> getDashboardData({String? projectId}) async {
    try {
      final response = await apiClient.getAdminDashboard(projectId);
      if (response['status'] == true || response['status'] == 'success') {
        return AdminDashboardModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load dashboard data');
    } catch (e) {
      rethrow;
    }
  }
}