import '../../../../data/datasources/remote/api_client.dart';
import '../models/recruitment_model.dart';

class AdminRecruitmentRepository {
  final ApiClient apiClient;

  AdminRecruitmentRepository({required this.apiClient});

  Future<RecruitmentDashboardModel> getDashboard() async {
    try {
      // final response = await apiClient.getRecruitmentDashboard();
      final response = {};
      if (response['status'] == 'success') {
        return RecruitmentDashboardModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load recruitment data');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RecruitedPersonModel>> getRecruitsByAdvisor(String advisorId) async {
    try {
      // final response = await apiClient.getRecruitsByAdvisor(advisorId);
      final response = {};
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => RecruitedPersonModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load recruits');
    } catch (e) {
      rethrow;
    }
  }
}