import 'dart:convert';
import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/project_model.dart';
import '../models/unit_model.dart'; // Import UnitModel

class AdminProjectRepository {
  final ApiClient apiClient;
  AdminProjectRepository({required this.apiClient});

  // Helper function to handle the String parsing issue globally
  dynamic _parseResponse(dynamic response) {
    if (response is String) {
      return jsonDecode(response);
    }
    return response;
  }

  // --- PROJECTS ---
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      var response = await apiClient.getAllProjects();
      response = _parseResponse(response);

      if (response['status'] == 'success') {
        final List data = response['data']['projects'] ?? [];
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load projects');
    } catch (e) { rethrow; }
  }

  Future<ProjectModel> getProjectDetails(int projectId) async {
    try {
      var response = await apiClient.getProjectDetails(projectId);
      response = _parseResponse(response);

      if (response['status'] == 'success') {
        return ProjectModel.fromJson(response['data']);
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> addProject({
    required String projectName, required String developerName, required String city,
    required String fullAddress, required String status, required String projectType,
    required String constructionStatus, required String marketValue, required String totalPlots,
    required String buildArea, required String reraNumber, required String location,
    required String ratePerSqft, required String budgetRange, required String description,
    required String reraApproved, required String amenities, required String specialties,
    File? video, File? brochure, required List<File> images,
  }) async {
    try {
      var response = await apiClient.addProject(
          projectName, developerName, city, fullAddress, status, projectType,
          constructionStatus, marketValue, totalPlots, buildArea, reraNumber,
          location, ratePerSqft, budgetRange, description, reraApproved,
          amenities, specialties, video, brochure, images
      );
      response = _parseResponse(response);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateProject(Map<String, dynamic> data) async {
    try {
      var response = await apiClient.updateProject(data);
      response = _parseResponse(response);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> deleteProject(int projectId) async {
    try {
      var response = await apiClient.deleteProject({"project_id": projectId});
      response = _parseResponse(response);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  // --- UNITS ---
  Future<List<UnitModel>> getUnits(int projectId) async {
    try {
      var response = await apiClient.getUnits(projectId);
      response = _parseResponse(response);

      if (response['status'] == 'success') {
        final List data = response['data']['units'] ?? [];
        return data.map((json) => UnitModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load units');
    } catch (e) { rethrow; }
  }

  Future<bool> addUnit(Map<String, dynamic> data) async {
    try {
      var response = await apiClient.addUnit(data);
      response = _parseResponse(response);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateUnit(Map<String, dynamic> data) async {
    try {
      var response = await apiClient.updateUnit(data);
      response = _parseResponse(response);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> deleteUnit(int unitId) async {
    try {
      var response = await apiClient.deleteUnit({"unit_id": unitId});
      response = _parseResponse(response);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}