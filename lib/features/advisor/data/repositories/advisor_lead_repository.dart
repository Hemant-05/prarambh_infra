import 'package:dio/dio.dart'; // NEW: Required for FormData
import '../../../../data/datasources/remote/api_client.dart';
import '../../../admin/data/models/lead_models.dart';

class AdvisorLeadRepository {
  final ApiClient apiClient;
  AdvisorLeadRepository({required this.apiClient});

  Future<List<LeadModel>> getLeads({required String advisorCode, String? stage}) async {
    try {
      // Pass null for source since we only filter by advisor and stage here
      final response = await apiClient.getLeads(advisorCode, stage, null);
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        List<LeadModel> leads = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              leads.add(LeadModel.fromJson(item));
            }
          } catch (e) {
            // Ignore malformed lead
          }
        }

        // Local filter fallback just in case backend returns everything
        if (stage != null && stage.isNotEmpty) {
          leads = leads.where((l) => l.stage.toLowerCase() == stage.toLowerCase()).toList();
        }
        return leads;
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> addLead(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.addLead(data);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateLead(String leadId, Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await apiClient.updateLead(leadId, formData);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  // Uses the dedicated optimized addNote endpoint
  Future<bool> addLeadNote(String leadId, String title, String time) async {
    try {
      final response = await apiClient.addLeadNote(leadId, {'title': title, 'time': time});
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}