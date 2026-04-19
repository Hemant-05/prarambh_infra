import 'package:flutter/material.dart';
import '../../../admin/data/models/lead_models.dart';
import '../../data/repositories/advisor_lead_repository.dart';

class AdvisorLeadProvider extends ChangeNotifier {
  final AdvisorLeadRepository repository;
  AdvisorLeadProvider({required this.repository});

  List<LeadModel> _leads = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<LeadModel> get leads => _leads;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  int? _initialPipelineTabIndex;
  int? get initialPipelineTabIndex => _initialPipelineTabIndex;

  void setPipelineTab(int index) {
    _initialPipelineTabIndex = index;
    notifyListeners();
  }

  void clearInitialPipelineTab() {
    _initialPipelineTabIndex = null;
  }

  Future<void> fetchLeads({required String advisorCode, String? stage}) async {
    _isLoading = true; notifyListeners();
    try {
      _leads = await repository.getLeads(advisorCode: advisorCode, stage: stage);
    } catch (e) {
      debugPrint('Fetch Advisor Leads Error: $e');
      _leads = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> addLead(Map<String, dynamic> data, String advisorCode) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addLead(data);
      if (success) await fetchLeads(advisorCode: advisorCode);
      return success;
    } catch (e) {
      debugPrint('Add Lead Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> updateLeadStage(String leadId, String newStage, String advisorCode, {Map<String, dynamic>? extraData}) async {
    _isSaving = true; notifyListeners();
    try {
      Map<String, dynamic> data = {"stage": newStage};
      if (extraData != null) data.addAll(extraData);

      final success = await repository.updateLead(leadId, data);
      await fetchLeads(advisorCode: advisorCode);
      return success;
    } catch (e) {
      debugPrint('Update Lead Stage Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  // NEW: Dedicated Add Note Function matching the Admin side
  Future<bool> addLeadNote(String leadId, String title, String time, String advisorCode, String currentStage) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addLeadNote(leadId, title, time);
      if (success) await fetchLeads(advisorCode: advisorCode);
      return success;
    } catch (e) {
      debugPrint('Add Lead Note Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}