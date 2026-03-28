import 'dart:convert';
import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/project_model.dart';
import '../models/unit_model.dart';

class AdminProjectRepository {
  final ApiClient apiClient;
  AdminProjectRepository({required this.apiClient});

  dynamic _parseResponse(dynamic response) {
    if (response is String) return jsonDecode(response);
    return response;
  }

  // --- PROJECTS ---

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      var response = await apiClient.getAllProjects();
      response = _parseResponse(response);
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load projects');
    } catch (e) { rethrow; }
  }

  Future<ProjectModel> getProjectDetails(String projectId) async {
    try {
      var response = await apiClient.getSingleProject(projectId);
      response = _parseResponse(response);
      if (response['status']) {
        return ProjectModel.fromJson(response['data']);
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> addProject({
    required String projectName,
    required String developerName,
    required String description,
    required String reraNumber,
    required String projectType,
    required String constructionStatus,
    required String fullAddress,
    required String location,
    required String city,
    required String marketValue,
    required String totalPlots,
    required String buildArea,
    required String ratePerSqft,
    required String budgetRange,
    required String amenities,
    required String specialties,
    File? videoFile,
    File? brochureFile,
    required List<File> projectImages,
  }) async {
    try {
      var response = await apiClient.addProject(
        projectName, developerName, description, reraNumber, projectType,
        constructionStatus, fullAddress, location, city, marketValue,
        totalPlots, buildArea, ratePerSqft, budgetRange, amenities,
        specialties, videoFile, brochureFile, projectImages,
      );
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> updateProject({
    required String id,
    String? projectName,
    String? developerName,
    String? description,
    String? projectType,
    String? constructionStatus,
    String? fullAddress,
    String? location,
    String? city,
    String? marketValue,
    String? totalPlots,
    String? buildArea,
    String? ratePerSqft,
    String? specialties,
    String? amenities,
    String? budgetRange,
    String? reraNumber,
    String? status,
    File? videoFile,
    File? brochureFile,
    List<File>? projectImages,
  }) async {
    try {
      var response = await apiClient.updateProject(
        id, projectName, developerName, description, projectType,
        constructionStatus, fullAddress, location, city, marketValue,
        totalPlots, buildArea, ratePerSqft, specialties, amenities,
        budgetRange, reraNumber, status, videoFile, brochureFile, projectImages,
      );
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      var response = await apiClient.deleteProject(projectId);
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }

  // --- UNITS ---

  Future<List<UnitModel>> getUnits({String? projectId}) async {
    try {
      var response = await apiClient.getUnits(projectId);
      response = _parseResponse(response);
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((json) => UnitModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load units');
    } catch (e) { rethrow; }
  }

  Future<bool> addUnit(Map<String, dynamic> data) async {
    try {
      var response = await apiClient.addUnit(data);
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> addMultipleUnits(Map<String, dynamic> data) async {
    try {
      var response = await apiClient.addMultipleUnits(data);
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> updateUnit(String unitId, Map<String, dynamic> data) async {
    try {
      var response = await apiClient.updateUnit(unitId, data);
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> deleteUnit(String unitId) async {
    try {
      var response = await apiClient.deleteUnit(unitId);
      response = _parseResponse(response);
      return response['status'];
    } catch (e) { rethrow; }
  }
}