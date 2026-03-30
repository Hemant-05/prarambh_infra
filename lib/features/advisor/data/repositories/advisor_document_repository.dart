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
        final List pData = personalResponse['data'] ?? [];
        allDocs.addAll(pData.map((json) => DocumentModel.fromJson(json)));
      }

      // 2. Fetch General Company Documents (Passing null for user_id)
      final generalResponse = await apiClient.getDocuments(null, null);
      if (generalResponse['status'] == true || generalResponse['status'] == 'success') {
        final List gData = generalResponse['data'] ?? [];
        allDocs.addAll(gData.map((json) => DocumentModel.fromJson(json)));
      }

      return allDocs;
    } catch (e) {
      rethrow;
    }
  }
}