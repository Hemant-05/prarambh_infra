import '../../../../data/datasources/remote/api_client.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import 'package:flutter/foundation.dart';

class ClientPropertyRepository {
  final ApiClient apiClient;

  ClientPropertyRepository({required this.apiClient});

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final response = await apiClient.getAllProjects();
      if (response != null && response['status'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get All Projects Error: $e');
      return [];
    }
  }

  Future<List<UnitModel>> getAllUnits({String? projectId}) async {
    try {
      final response = await apiClient.getUnits(projectId);
      if (response != null && response['status'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => UnitModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get Units Error: $e');
      return [];
    }
  }

  Future<ProjectModel?> getProjectDetails(String id) async {
    try {
      final response = await apiClient.getSingleProject(id);
      if (response != null && response['status'] == true) {
        return ProjectModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Get Project Details Error: $e');
      return null;
    }
  }
}
