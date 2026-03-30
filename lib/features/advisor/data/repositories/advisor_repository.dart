import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/advisor_dashboard_model.dart';

class AdvisorRepository {
  final ApiClient apiClient;
  AdvisorRepository({required this.apiClient});

  Future<AdvisorDashboardModel> getDashboardData(String advisorCode) async {
    try {
      final response = await apiClient.getAdvisorDashboard(advisorCode);
      if (response['status'] == true || response['status'] == 'success') {
        return AdvisorDashboardModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor dashboard');
    } catch (e) {
      rethrow;
    }
  }
}