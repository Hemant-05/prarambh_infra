import '../../../../data/datasources/remote/api_client.dart';
import '../models/lead_models.dart';

class AdminLeadRepository {
  final ApiClient apiClient;
  AdminLeadRepository({required this.apiClient});

  Future<List<LeadModel>> getNewLeads() async {
    try {
      final response = await apiClient.getNewLeads();
      if (response['status'] == 'success') {
        return (response['data'] as List).map((e) => LeadModel.fromJson(e)).toList();
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<List<AdvisorAssignModel>> getAvailableAdvisors() async {
    try {
      final response = await apiClient.getAvailableAdvisors();
      if (response['status'] == 'success') {
        return (response['data'] as List).map((e) => AdvisorAssignModel.fromJson(e)).toList();
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> assignLead(String leadId, String advisorId) async {
    try {
      final response = await apiClient.assignLead({"lead_id": leadId, "advisor_id": advisorId});
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}