import '../../../../data/datasources/remote/api_client.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';

class AdvisorProjectRepository {
  final ApiClient apiClient;

  AdvisorProjectRepository({required this.apiClient});

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await apiClient.getAllProjects();
      // Safely parse regardless of string or raw json response
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load projects');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UnitModel>> getUnits(String projectId) async {
    try {
      final response = await apiClient.getUnits(projectId);
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => UnitModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load units');
    } catch (e) {
      rethrow;
    }
  }
}