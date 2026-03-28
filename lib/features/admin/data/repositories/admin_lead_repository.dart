import '../../../../data/datasources/remote/api_client.dart';
import '../models/lead_models.dart';

class AdminLeadRepository {
  final ApiClient apiClient;
  AdminLeadRepository({required this.apiClient});

  /// Fetch all leads. Pass [advisorCode] to filter by advisor.
  Future<List<LeadModel>> getLeads({String? advisorCode}) async {
    try {
      final response = await apiClient.getLeads(advisorCode);
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((e) => LeadModel.fromJson(e)).toList();
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<LeadModel> getSingleLead(String id) async {
    try {
      final response = await apiClient.getSingleLead(id);
      if (response['status']) {
        return LeadModel.fromJson(response['data']);
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> addLead(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.addLead(data);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> updateLead(String leadId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.updateLead(leadId, data);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> deleteLead(String leadId) async {
    try {
      final response = await apiClient.deleteLead(leadId);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> addLeadToPriority(String leadId) async {
    try {
      final response = await apiClient.addLeadToPriority(leadId);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<List<LeadModel>> getPriorityLeads() async {
    try {
      final response = await apiClient.getPriorityLeads();
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((e) => LeadModel.fromJson(e)).toList();
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> removeLeadFromPriority(String leadId) async {
    try {
      final response = await apiClient.removeLeadFromPriority(leadId);
      return response['status'];
    } catch (e) { rethrow; }
  }

  // NOTE: getAvailableAdvisors — no dedicated endpoint in new ApiClient.
  // Use AdminAdvisorRepository.getAllAdvisors() instead.
  Future<List<AdvisorAssignModel>> getAvailableAdvisors() async {
    throw UnimplementedError(
      'Use AdminAdvisorRepository.getAllAdvisors() for this data.',
    );
  }
}