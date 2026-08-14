import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_document_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdminDocumentProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminDocumentRepository repository;

  AdminDocumentProvider({required this.repository});

  List<DocumentModel> _documents = [];
  bool _isSaving = false;

  List<DocumentModel> get documents => _documents;
  bool get isSaving => _isSaving;
  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  Map<String, List<DocumentModel>> get groupedDocuments {
    final map = <String, List<DocumentModel>>{};
    for (var doc in _documents) {
      // Hide personal documents from general management view
      if (doc.category.toLowerCase() == 'personal') continue;
      
      String categoryName = doc.category;
      final lowerCat = categoryName.toLowerCase();
      
      if (lowerCat.contains('business plan')) {
        categoryName = 'Advisor Business Plan';
      } else if (lowerCat == 'legal documents' || lowerCat == 'legal') {
        categoryName = 'Company Legal Documents';
      } else if (lowerCat == 'other') {
        categoryName = 'Others';
      } else if (lowerCat == 'project broucher' || lowerCat == 'project brochure') {
        categoryName = 'Project Brochures';
      } else if (lowerCat == 'project site map') {
        categoryName = 'Project Site Maps';
      } else if (lowerCat.contains('rules') && lowerCat.contains('regulations')) {
        categoryName = 'Company Rules & Regulations';
      } else if (lowerCat == 'rera') {
        categoryName = 'RERA';
      }
      
      if (!map.containsKey(categoryName)) map[categoryName] = [];
      map[categoryName]!.add(doc);
    }
    return map;
  }

  int get managedDocumentsCount {
    return _documents.where((doc) => doc.category.toLowerCase() != 'personal').length;
  }

  Future<void> fetchDocuments({String? userId, String? category}) async {
    setLoading(true);
    setError(null);
    try {
      _documents = await repository.getDocuments(userId: userId, category: category);
    } catch (e) {
      debugPrint('Fetch Docs Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _documents = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> uploadDocument({required String name, required String category, String? userId, required File documentFile}) async {
    isSaving = true;
    try {
      final success = await repository.addDocument(name: name, category: category, userId: userId, documentFile: documentFile);
      if (success) await fetchDocuments(userId: userId, category: category);
      return success;
    } catch (e) {
      debugPrint('Upload Document Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> updateDocument({required String id, String? name, String? category, File? documentFile}) async {
    isSaving = true;
    try {
      final success = await repository.updateDocument(id: id, name: name, category: category, documentFile: documentFile);
      if (success) await fetchDocuments();
      return success;
    } catch (e) {
      debugPrint('Update Document Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    isSaving = true;
    try {
      final success = await repository.deleteDocument(id);
      if (success) _documents.removeWhere((d) => d.id == id);
      return success;
    } catch (e) {
      debugPrint('Delete Document Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }
}