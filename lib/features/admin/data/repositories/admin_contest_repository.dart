import '../../../../data/datasources/remote/api_client.dart';
import '../models/contest_model.dart';

class AdminContestRepository {
  final ApiClient apiClient;
  AdminContestRepository({required this.apiClient});

  Future<List<ContestModel>> getContests() async {
    try {
      final response = await apiClient.getContests();
      if (response['status'] == 'success') {
        return (response['data'] as List).map((e) => ContestModel.fromJson(e)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load contests');
    } catch (e) { rethrow; }
  }

  Future<bool> createContest(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.createContest(data);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}