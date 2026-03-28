import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_document_repository.dart';

class AdvisorDocumentProvider extends ChangeNotifier {
  final AdvisorDocumentRepository repository;

  AdvisorDocumentProvider({required this.repository});

  List<DocumentModel> _documents = [];
  bool _isLoading = false;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;

  Future<void> fetchDocuments(String advisorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await repository.getAdvisorDocuments(advisorId);
    } catch (e) {
      debugPrint('Error fetching advisor docs: $e');
      _documents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}