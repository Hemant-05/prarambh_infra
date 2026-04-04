import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import '../../../../data/datasources/remote/api_client.dart';

class AdvisorDocumentRepository {
  final ApiClient apiClient;

  AdvisorDocumentRepository({required this.apiClient});

  Future<List<DocumentModel>> getAdvisorDocuments(String advisorId) async {
    try {
      List<DocumentModel> allDocs = [];

      // 1. Fetch Advisor's Personal Documents
      final personalResponse = await apiClient.getDocuments(advisorId, null);
      if (personalResponse['status'] == true || personalResponse['status'] == 'success') {
        final data = personalResponse['data'];
        if (data is List) {
          allDocs.addAll(data.map((json) => DocumentModel.fromJson(json)));
        }
      }

      final generalResponse = await apiClient.getDocuments(null, null);
      if (generalResponse['status'] == true || generalResponse['status'] == 'success') {
        final data = generalResponse['data'];
        if (data is List) {
          final generalDocs = data.map((json) => DocumentModel.fromJson(json)).toList();
          allDocs.addAll(generalDocs.where((doc) => 
              doc.userId == null || doc.userId == '' || doc.userId == '0'
          ));
        }
      }

      return allDocs;
    } catch (e) {
      rethrow;
    }
  }
}