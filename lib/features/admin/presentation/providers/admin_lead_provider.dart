import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/models/lead_models.dart';
import '../../data/repositories/admin_lead_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdminLeadProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminLeadRepository repository;
  AdminLeadProvider({required this.repository});

  List<LeadModel> _leads = [];
  List<LeadModel> _priorityLeads = [];
  List<LeadModel> _unassignedLeads = [];
  List<AdvisorAssignModel> _availableAdvisors = [];
  bool _isSaving = false;

  List<LeadModel> get leads => _leads;
  List<LeadModel> get priorityLeads => _priorityLeads;
  List<LeadModel> get unassignedLeads => _unassignedLeads;
  List<AdvisorAssignModel> get availableAdvisors => _availableAdvisors;
  bool get isSaving => _isSaving;
  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  Future<void> fetchLeads({String? advisorCode, String? stage}) async {
    setLoading(true);
    setError(null);
    try {
      _leads = await repository.getLeads(advisorCode: advisorCode, stage: stage);
    } catch (e) {
      debugPrint('Fetch Leads Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _leads = [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchUnassignedLeads() async {
    setLoading(true);
    setError(null);
    try {
      _unassignedLeads = await repository.getUnassignedLeads();
    } catch (e) {
      debugPrint('Fetch Unassigned Leads Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _unassignedLeads = [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchPriorityLeads() async {
    setLoading(true);
    setError(null);
    try {
      _priorityLeads = await repository.getPriorityLeads();
    } catch (e) {
      debugPrint('Fetch Priority Leads Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _priorityLeads = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addLead(Map<String, dynamic> data) async {
    isSaving = true;
    try {
      final success = await repository.addLead(data);
      if (success) await fetchLeads();
      return success;
    } catch (e) {
      debugPrint('Add Lead Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> addLeadToPriority(String leadId) async {
    isSaving = true;
    try {
      final success = await repository.addLeadToPriority(leadId);
      if (success) {
        await fetchPriorityLeads();
      }
      return success;
    } catch (e) {
      debugPrint('Add Lead Priority Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> removeLeadFromPriority(String leadId) async {
    isSaving = true;
    try {
      final success = await repository.removeLeadFromPriority(leadId);
      if (success) {
        await fetchPriorityLeads();
      }
      return success;
    } catch (e) {
      debugPrint('Remove Lead Priority Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> updateLeadStage(String leadId, String newStage, {Map<String, dynamic>? extraData}) async {
    isSaving = true;
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
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> addLeadNote(String leadId, String title, String time) async {
    isSaving = true;
    try {
      return await repository.addLeadNote(leadId, title, time);
    } catch (e) {
      debugPrint('Add Note Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<void> fetchAdvisorsForAssignment() async {
    setLoading(true);
    try {
      _availableAdvisors = await repository.getAvailableAdvisors();
    } catch (e) {
      debugPrint(e.toString());
      setError(UIHelper.summarizeError(e.toString()));
    } finally {
      setLoading(false);
    }
  }

  Future<bool> assignLeadToAdvisor(String leadId, String advisorCode) async {
    isSaving = true;
    try {
      final success = await repository.assignLeadToAdvisor(leadId, advisorCode);
      if (success) {
        await fetchUnassignedLeads();
        await fetchLeads();
      }
      return success;
    } catch (e) {
      debugPrint('Assign Lead Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<LeadModel?> getSingleLead(String id) async {
    setLoading(true);
    try {
      return await repository.getSingleLead(id);
    } catch (e) {
      debugPrint('Get Single Lead Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return null;
    } finally {
      setLoading(false);
    }
  }
}