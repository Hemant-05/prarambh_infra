import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_document_repository.dart';

class AdminDocumentProvider extends ChangeNotifier {
  final AdminDocumentRepository repository;

  AdminDocumentProvider({required this.repository});

  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  // Group documents dynamically by their actual category
  Map<String, List<DocumentModel>> get groupedDocuments {
    final map = <String, List<DocumentModel>>{};
    for (var doc in _documents) {
      if (!map.containsKey(doc.category)) map[doc.category] = [];
      map[doc.category]!.add(doc);
    }
    return map;
  }

  Future<void> fetchDocuments({String? userId, String? category, String? general}) async {
    _isLoading = true; notifyListeners();
    try {
      _documents = await repository.getDocuments(userId: userId, category: category, general: general);
    } catch (e) {
      debugPrint('Fetch Docs Error: $e');
      _documents = []; // Clear docs on error instead of showing fake data
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> uploadDocument({required String name, required String category, String? userId, required File documentFile}) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addDocument(name: name, category: category, userId: userId, documentFile: documentFile);
      if (success) await fetchDocuments(userId: userId, category: category);
      return success;
    } catch (e) {
      debugPrint('Upload Document Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> updateDocument({required String id, String? name, File? documentFile}) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateDocument(id: id, name: name, documentFile: documentFile);
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