import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_document_repository.dart';
import '../../data/models/project_document_model.dart';

class AdminDocumentProvider extends ChangeNotifier {
  final AdminDocumentRepository repository;

  AdminDocumentProvider({required this.repository});

  List<ProjectDocumentModel> _documents = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<ProjectDocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  // Group documents by category for the Expandable UI
  Map<String, List<ProjectDocumentModel>> get groupedDocuments {
    final map = <String, List<ProjectDocumentModel>>{};
    for (var doc in _documents) {
      if (!map.containsKey(doc.category)) map[doc.category] = [];
      map[doc.category]!.add(doc);
    }
    return map;
  }

  Future<void> fetchDocuments({String? userId, String? category, String? general}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await repository.getDocuments(
        userId: userId,
        category: category,
        general: general,
      );
    } catch (e) {
      // Mock data for UI testing if API isn't ready
      _documents = [
        ProjectDocumentModel(id: '1', title: 'Divine Valley Site Map', category: 'Project Site Maps', type: 'PDF', size: '4.2 MB', lastUpdated: '2h ago'),
        ProjectDocumentModel(id: '2', title: 'Shivangan Valley Site Map', category: 'Project Site Maps', type: 'PDF', size: '3.8 MB', lastUpdated: 'Yesterday'),
        ProjectDocumentModel(id: '3', title: 'Divine Valley RERA Cert', category: 'RERA Certification', type: 'PDF', size: '1.5 MB', lastUpdated: '5 days ago'),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String name,
    required String category,
    String? userId,
    required File documentFile,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addDocument(
        name: name,
        category: category,
        userId: userId,
        documentFile: documentFile,
      );
      if (success) await fetchDocuments(userId: userId, category: category);
      return success;
    } catch (e) {
      debugPrint('Upload Document Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> updateDocument({
    required String id,
    String? name,
    File? documentFile,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateDocument(
        id: id,
        name: name,
        documentFile: documentFile,
      );
      if (success) await fetchDocuments();
      return success;
    } catch (e) {
      debugPrint('Update Document Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> deleteDocument(String id) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.deleteDocument(id);
      if (success) _documents.removeWhere((d) => d.id == id);
      return success;
    } catch (e) {
      debugPrint('Delete Document Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}