import '../../../../data/datasources/remote/api_client.dart';
import '../../../admin/data/models/contest_model.dart';

class AdvisorContestRepository {
  final ApiClient apiClient;

  AdvisorContestRepository({required this.apiClient});

  Future<List<ContestModel>> getContests() async {
    try {
      final response = await apiClient.getContests();
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => ContestModel.fromJson(e)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load contests');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> joinContest(String contestId, String advisorCode) async {
    try {
      final response = await apiClient.joinContest({
        'contest_id': contestId,
        'advisor_code': advisorCode,
      });
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}