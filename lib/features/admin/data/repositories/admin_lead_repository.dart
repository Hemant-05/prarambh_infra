import 'package:dio/dio.dart';

import '../../../../data/datasources/remote/api_client.dart';
import '../models/lead_models.dart';

class AdminLeadRepository {
  final ApiClient apiClient;
  AdminLeadRepository({required this.apiClient});

  Future<List<LeadModel>> getLeads({String? advisorCode, String? stage}) async {
    try {
      // API client now accepts stage directly if needed, but we pass advisor code
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
            // safely ignore
          }
        }

        if (stage != null && stage.isNotEmpty) {
          leads = leads.where((l) => l.stage.toLowerCase() == stage.toLowerCase()).toList();
        }
        return leads;
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<List<LeadModel>> getUnassignedLeads() async {
    try {
      final response = await apiClient.getUnassignedLeads();
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        List<LeadModel> leads = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) leads.add(LeadModel.fromJson(item));
          } catch (_) {}
        }
        return leads;
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

  Future<bool> addLeadNote(String leadId, String title, String time) async {
    try {
      final response = await apiClient.addLeadNote(leadId, {'title': title, 'time': time});
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> deleteLead(String leadId) async {
    try {
      final response = await apiClient.deleteLead(leadId);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> assignLeadToAdvisor(String leadId, String advisorCode) async {
    try {
      final response = await apiClient.assignLeadToAdvisor(leadId, advisorCode);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<List<AdvisorAssignModel>> getAvailableAdvisors() async {
    try {
      final response = await apiClient.getAdvisorsForAssignment();
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => AdvisorAssignModel.fromJson(e)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load advisors');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addLeadToPriority(String leadId) async {
    try {
      final response = await apiClient.addLeadToPriority(leadId);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<List<LeadModel>> getPriorityLeads() async {
    try {
      final response = await apiClient.getPriorityLeads(null);
      if (response['status']) {
        final List data = response['data'] ?? [];
        List<LeadModel> leads = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) leads.add(LeadModel.fromJson(item));
          } catch (_) {}
        }
        return leads;
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
}