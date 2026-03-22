import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_dashboard_model.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({required this.apiClient});

  Future<AdminDashboardModel> getDashboardData(int userId) async {
    try {
      final response = await apiClient.getManagerDashboard(userId);

      if (response['status'] == 'success') {
        // Assuming your backend nests the data inside a 'data' object
        return AdminDashboardModel.fromJson(response['data'] ?? response);
      } else {
        throw Exception(response['message'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      rethrow;
    }
  }
}