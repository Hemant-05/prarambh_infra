import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_income_model.dart';

class AdvisorIncomeRepository {
  final ApiClient apiClient;

  AdvisorIncomeRepository({required this.apiClient});

  Future<AdvisorIncomeModel> getAdvisorIncome(String advisorCode) async {
    try {
      final response = await apiClient.getAdvisorIncome(advisorCode);
      if (response['status'] == true) {
        return AdvisorIncomeModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor income');
    } catch (e) {
      rethrow;
    }
  }
}
