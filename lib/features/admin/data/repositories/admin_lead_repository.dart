import '../../../../data/datasources/remote/api_client.dart';
import '../models/lead_models.dart';

class AdminLeadRepository {
  final ApiClient apiClient;
  AdminLeadRepository({required this.apiClient});

  Future<List<LeadModel>> getNewLeads(int adminId) async {
    try {
      final response = await apiClient.getLeads(adminId, "Admin", "New");
      if (response['status'] == 'success') {
        return (response['data'] as List).map((e) => LeadModel.fromJson(e)).toList();
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  // NOTE: Still missing in Postman. Ask backend dev for the available advisors endpoint!
  Future<List<AdvisorAssignModel>> getAvailableAdvisors() async {
    throw Exception("Endpoint missing from API");
  }

  Future<bool> assignLead(String leadId, String advisorId) async {
    try {
      final response = await apiClient.updateLeadDetails({
        "lead_id": leadId,
        "advisor_id": advisorId
      });
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}