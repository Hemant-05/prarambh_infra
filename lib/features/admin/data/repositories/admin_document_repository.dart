import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/project_document_model.dart';

class AdminDocumentRepository {
  final ApiClient apiClient;

  AdminDocumentRepository({required this.apiClient});

  Future<List<ProjectDocumentModel>> getDocuments({
    String? userId,
    String? category,
    String? general,
  }) async {
    try {
      final response = await apiClient.getDocuments(userId, category, general);
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => ProjectDocumentModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load documents');
    } catch (e) { rethrow; }
  }

  Future<ProjectDocumentModel> getSingleDocument(String id) async {
    try {
      final response = await apiClient.getSingleDocument(id);
      if (response['status'] == 'success') {
        return ProjectDocumentModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load document');
    } catch (e) { rethrow; }
  }

  Future<bool> addDocument({
    required String name,
    required String category,
    String? userId,
    required File documentFile,
  }) async {
    try {
      final response = await apiClient.addDocument(name, category, userId, documentFile);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateDocument({
    required String id,
    String? name,
    File? documentFile,
  }) async {
    try {
      final response = await apiClient.updateDocument(id, name, documentFile);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      final response = await apiClient.deleteDocument(id);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}