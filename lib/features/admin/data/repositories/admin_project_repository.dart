import '../../../../data/datasources/remote/api_client.dart';
import '../models/project_model.dart';

class AdminProjectRepository {
  final ApiClient apiClient;
  AdminProjectRepository({required this.apiClient});

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final response = await apiClient.getAllProjects();
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load projects');
    } catch (e) { rethrow; }
  }

  Future<bool> addProject(Map<String, dynamic> projectData) async {
    try {
      final response = await apiClient.addProject(projectData);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}