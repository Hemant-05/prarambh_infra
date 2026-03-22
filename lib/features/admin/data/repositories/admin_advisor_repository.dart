import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_application_model.dart';

class AdminAdvisorRepository {
  final ApiClient apiClient;

  AdminAdvisorRepository({required this.apiClient});

  Future<List<AdvisorApplicationModel>> getApplications() async {
    try {
      final response = await apiClient.getAdvisorApplications();
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AdvisorApplicationModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load applications');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateStatus(String advisorId, String status, {String? reason}) async {
    try {
      final response = await apiClient.updateAdvisorStatus({
        "advisor_id": advisorId,
        "status": status,
        "reason": reason ?? "",
      });
      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}