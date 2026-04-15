import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/advisor_dashboard_model.dart';
import '../models/resale_unit_model.dart';

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

  Future<List<ResaleUnitModel>> getResaleUnits() async {
    try {
      final response = await apiClient.filterUnits('Resale');
      if (response['status'] == true || response['status'] == 'success') {
        final data = response['data'] as List? ?? [];
        return data.map((e) => ResaleUnitModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}