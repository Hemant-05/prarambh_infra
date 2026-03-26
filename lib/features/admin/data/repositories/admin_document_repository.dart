import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/project_document_model.dart';

class AdminDocumentRepository {
  final ApiClient apiClient;

  AdminDocumentRepository({required this.apiClient});

  Future<List<ProjectDocumentModel>> getDocuments() async {
    try {
      final response = await apiClient.getDocuments();
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => ProjectDocumentModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load documents');
    } catch (e) { rethrow; }
  }

  Future<bool> uploadDocument(File file, String name, String category, int uploaderId) async {
    try {
      final response = await apiClient.uploadDocument(file, uploaderId.toString(), name, category);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}