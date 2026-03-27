import 'package:flutter/material.dart';
import '../../data/models/lead_models.dart';
import '../../data/repositories/admin_lead_repository.dart';

class AdminLeadProvider extends ChangeNotifier {
  final AdminLeadRepository repository;
  AdminLeadProvider({required this.repository});

  List<LeadModel> _leads = [];
  List<AdvisorAssignModel> _availableAdvisors = [];
  bool _isLoading = false;

  List<LeadModel> get leads => _leads;
  List<AdvisorAssignModel> get availableAdvisors => _availableAdvisors;
  bool get isLoading => _isLoading;

  List<PipelineLeadModel> _pipelineLeads = [];
  bool _isLoadingPipeline = false;

  List<PipelineLeadModel> get pipelineLeads => _pipelineLeads;
  bool get isLoadingPipeline => _isLoadingPipeline;

  Future<void> fetchPipelineLeads(String stage) async {
    _isLoadingPipeline = true; notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _pipelineLeads = [
        PipelineLeadModel(id: '1', name: 'Arjun Mehta', project: 'Divine Valley', advisorName: 'RAHUL SHARMA', lastActiveDate: '24 Oct 2023', stage: stage),
        PipelineLeadModel(id: '2', name: 'Priya Singh', project: 'Divine Valley', advisorName: 'ANJALI RAO', lastActiveDate: '23 Oct 2023', stage: stage),
        PipelineLeadModel(id: '3', name: 'Vikram Chatterjee', project: 'The Grand Residency', advisorName: 'RAHUL SHARMA', lastActiveDate: '22 Oct 2023', stage: stage),
        PipelineLeadModel(id: '4', name: 'Suresh Iyer', project: 'Skyline Heights', advisorName: 'KARAN SINGH', lastActiveDate: '21 Oct 2023', stage: stage),
        PipelineLeadModel(id: '5', name: 'Meera Kapur', project: 'Divine Valley', advisorName: 'RAHUL SHARMA', lastActiveDate: '20 Oct 2023', stage: stage),
      ];
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoadingPipeline = false; notifyListeners(); }
  }

  /// Fetch all leads, optionally filtered by [advisorCode].
  Future<void> fetchLeads({String? advisorCode}) async {
    _isLoading = true; notifyListeners();
    try {
      _leads = await repository.getLeads(advisorCode: advisorCode);
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> addLead(Map<String, dynamic> data) async {
    _isLoading = true; notifyListeners();
    try {
      final success = await repository.addLead(data);
      if (success) await fetchLeads();
      return success;
    } catch (e) {
      debugPrint('Add Lead Error: $e');
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> updateLead(String leadId, Map<String, dynamic> data) async {
    _isLoading = true; notifyListeners();
    try {
      final success = await repository.updateLead(leadId, data);
      if (success) await fetchLeads();
      return success;
    } catch (e) {
      debugPrint('Update Lead Error: $e');
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> removeLead(String leadId) async {
    _isLoading = true; notifyListeners();
    try {
      final success = await repository.deleteLead(leadId);
      if (success) _leads.removeWhere((l) => l.id == leadId);
      return success;
    } catch (e) {
      debugPrint('Delete Lead Error: $e');
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> markAsPriority(String leadId) async {
    try {
      return await repository.addLeadToPriority(leadId);
    } catch (e) {
      debugPrint('Mark Priority Error: $e');
      return false;
    }
  }

  Future<bool> unmarkPriority(String leadId) async {
    try {
      return await repository.removeLeadFromPriority(leadId);
    } catch (e) {
      debugPrint('Unmark Priority Error: $e');
      return false;
    }
  }

  Future<void> fetchAdvisorsForAssignment() async {
    _isLoading = true; notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _availableAdvisors = [
        AdvisorAssignModel(id: '101', name: 'Michael Thorne', isOnline: true, activeLeads: 4, conversionRate: '28% Conv.', isWarning: false),
        AdvisorAssignModel(id: '102', name: 'Elena Rodriguez', isOnline: false, activeLeads: 2, conversionRate: '34% Conv.', isWarning: false),
        AdvisorAssignModel(id: '103', name: 'David Chen', isOnline: true, activeLeads: 8, conversionRate: '19% Conv.', isWarning: true),
        AdvisorAssignModel(id: '104', name: 'Jessica Miller', isOnline: true, activeLeads: 5, conversionRate: '22% Conv.', isWarning: false),
        AdvisorAssignModel(id: '105', name: 'Marcus Vane', isOnline: true, activeLeads: 12, conversionRate: '41% Conv.', isWarning: false),
      ];
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoading = false; notifyListeners(); }
  }
}