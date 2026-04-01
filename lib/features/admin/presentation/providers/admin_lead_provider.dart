import 'package:flutter/material.dart';
import '../../data/models/lead_models.dart';
import '../../data/repositories/admin_lead_repository.dart';

class AdminLeadProvider extends ChangeNotifier {
  final AdminLeadRepository repository;
  AdminLeadProvider({required this.repository});

  List<LeadModel> _leads = [];
  List<LeadModel> _unassignedLeads = [];
  List<AdvisorAssignModel> _availableAdvisors = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<LeadModel> get leads => _leads;
  List<LeadModel> get unassignedLeads => _unassignedLeads;
  List<AdvisorAssignModel> get availableAdvisors => _availableAdvisors;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> fetchLeads({String? advisorCode, String? stage}) async {
    _isLoading = true; notifyListeners();
    try {
      _leads = await repository.getLeads(advisorCode: advisorCode, stage: stage);
    } catch (e) {
      debugPrint('Fetch Leads Error: $e');
      _leads = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> fetchUnassignedLeads() async {
    _isLoading = true; notifyListeners();
    try {
      _unassignedLeads = await repository.getUnassignedLeads();
    } catch (e) {
      debugPrint('Fetch Unassigned Leads Error: $e');
      _unassignedLeads = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> addLead(Map<String, dynamic> data) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addLead(data);
      if (success) await fetchLeads();
      return success;
    } catch (e) {
      debugPrint('Add Lead Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> updateLeadStage(String leadId, String newStage, {Map<String, dynamic>? extraData}) async {
    _isSaving = true; notifyListeners();
    try {
      Map<String, dynamic> data = {"stage": newStage};
      if (extraData != null) data.addAll(extraData);

      final success = await repository.updateLead(leadId, data);
      if(success){
        fetchLeads();
      }
      return success;
    } catch (e) {
      debugPrint('Update Lead Stage Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> addLeadNote(String leadId, String title, String time) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.addLeadNote(leadId, title, time);
    } catch (e) {
      debugPrint('Add Note Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<void> fetchAdvisorsForAssignment() async {
    _isLoading = true; notifyListeners();
    try {
      _availableAdvisors = await repository.getAvailableAdvisors();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> assignLeadToAdvisor(String leadId, String advisorCode) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.assignLeadToAdvisor(leadId, advisorCode);
      if (success) {
        await fetchUnassignedLeads();
        await fetchLeads();
      }
      return success;
    } catch (e) {
      debugPrint('Assign Lead Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}