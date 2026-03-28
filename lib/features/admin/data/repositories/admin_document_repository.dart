import 'dart:io';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import '../../../../data/datasources/remote/api_client.dart';

class AdminDocumentRepository {
  final ApiClient apiClient;

  AdminDocumentRepository({required this.apiClient});

  Future<List<DocumentModel>> getDocuments({String? userId, String? category, String? general}) async {
    try {
      final response = await apiClient.getDocuments(userId, category, general);
      // THE FIX: Accept boolean true
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((json) => DocumentModel.fromJson(json)).toList();
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

  Future<bool> updateDocument({required String id, String? name, File? documentFile}) async {
    try {
      final response = await apiClient.updateDocument(id, name, documentFile);
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