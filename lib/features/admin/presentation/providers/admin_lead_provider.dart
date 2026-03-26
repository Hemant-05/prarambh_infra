import 'package:flutter/material.dart';
import '../../data/models/lead_models.dart';
import '../../data/repositories/admin_lead_repository.dart';

class AdminLeadProvider extends ChangeNotifier {
  final AdminLeadRepository repository;
  AdminLeadProvider({required this.repository});

  List<LeadModel> _newLeads = [];
  List<AdvisorAssignModel> _availableAdvisors = [];
  bool _isLoading = false;

  List<LeadModel> get newLeads => _newLeads;
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
      // Mock Data matching Screenshot 3 exactly
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

  Future<void> fetchNewLeads(int adminId) async {
    _isLoading = true; notifyListeners();
    try {
      _newLeads = await repository.getNewLeads(adminId);
      // Mock Data matching your UI exactly
      /*await Future.delayed(const Duration(milliseconds: 500));
      _newLeads = [
        LeadModel(id: '1', source: 'WEBSITE INQUIRY', timeAgo: '2M AGO', name: 'Jonathan Miller', email: 'j.miller@example.com', phone: '+1 555-0198', projectName: 'Skyline Penthouse B-12', projectImage: 'url', priority: 'High Priority', notes: '"Looking for commercial property in Chicago. Budget: 2M."', tags: ['INBOUND', 'COMMERCIAL', 'US-IL']),
        LeadModel(id: '2', source: 'CONTACT FORM', timeAgo: '15M AGO', name: 'Sarah Jenkins', email: 'sarah.j@webmail.com', phone: '+1 555-0421', projectName: 'Oakwood Family Villa', projectImage: 'url', priority: 'High Priority', notes: '"Looking for commercial property in Chicago. Budget: 2M."', tags: ['INBOUND', 'COMMERCIAL', 'US-IL']),
        LeadModel(id: '3', source: 'PROPERTY PORTAL', timeAgo: '3H AGO', name: 'Elena Rodriguez', email: 'elena.r@lifestyle.com', phone: '+1 555-0876', projectName: 'Harbor View Condos', projectImage: 'url'),
      ];*/
    } catch (e) { debugPrint(e.toString()); } finally { _isLoading = false; notifyListeners(); }
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
    } catch (e) { debugPrint(e.toString()); } finally { _isLoading = false; notifyListeners(); }
  }
}