import 'dart:io';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import '../../../../data/datasources/remote/api_client.dart';

class AdminDocumentRepository {
  final ApiClient apiClient;

  AdminDocumentRepository({required this.apiClient});

  Future<List<DocumentModel>> getDocuments({String? userId, String? category}) async {
    try {
      final response = await apiClient.getDocuments(userId, category);
      if (response['status'] == true || response['status'] == 'success') {
        final data = response['data'];
        if (data is List) {
          return data.map((json) => DocumentModel.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception(response['message'] ?? 'Failed to load documents');
    } catch (e) { rethrow; }
  }

  Future<DocumentModel> getSingleDocument(String id) async {
    try {
      final response = await apiClient.getSingleDocument(id);
      if (response['status']) {
        return DocumentModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load document');
    } catch (e) { rethrow; }
  }

  Future<bool> addDocument({required String name, required String category, String? userId, required File documentFile}) async {
    try {
      final response = await apiClient.addDocument(name, category, userId, documentFile);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> updateDocument({required String id, String? name, String? category, File? documentFile}) async {
    try {
      // Fixed: Added category
      final response = await apiClient.updateDocument(id, name, category, documentFile);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      final response = await apiClient.deleteDocument(id);
      return response['status'];
    } catch (e) { rethrow; }
  }
}