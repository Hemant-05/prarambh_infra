import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_document_repository.dart';
import '../../data/models/project_document_model.dart';

class AdminDocumentProvider extends ChangeNotifier {
  final AdminDocumentRepository repository;

  AdminDocumentProvider({required this.repository});

  List<ProjectDocumentModel> _documents = [];
  bool _isLoading = false;

  List<ProjectDocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;

  // Group documents by category for the Expandable UI
  Map<String, List<ProjectDocumentModel>> get groupedDocuments {
    final map = <String, List<ProjectDocumentModel>>{};
    for (var doc in _documents) {
      if (!map.containsKey(doc.category)) map[doc.category] = [];
      map[doc.category]!.add(doc);
    }
    return map;
  }

  Future<void> fetchDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await repository.getDocuments();
    } catch (e) {
      // Mock Data for UI testing if API isn't ready
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
}