import '../../../../data/datasources/remote/api_client.dart';
import '../models/admin_dashboard_model.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({required this.apiClient});

  /// NOTE: The new ApiClient does not have a dedicated /dashboard endpoint.
  /// Dashboard data should be composed from getAllProjects(), getLeads(),
  /// getAllAdvisors(), and getLeaderboard() calls.
  Future<AdminDashboardModel> getDashboardData() async {
    throw UnimplementedError(
      'No dedicated /dashboard endpoint exists in the new ApiClient. '
      'Compose dashboard from getAllProjects(), getLeads(), getAllAdvisors(), getLeaderboard().',
    );
  }
}