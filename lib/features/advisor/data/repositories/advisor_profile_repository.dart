import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_profile_model.dart';

class AdvisorProfileRepository {
  final ApiClient apiClient;

  AdvisorProfileRepository({required this.apiClient});

  Future<AdvisorProfileModel> getAdvisorProfile(String advisorId) async {
    try {
      final response = await apiClient.getSingleAdvisor(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return AdvisorProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load profile details');
    } catch (e) {
      rethrow;
    }
  }
}