import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/models/team_models.dart';
import '../../data/repositories/admin_team_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdminTeamProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminTeamRepository repository;
  AdminTeamProvider({required this.repository});

  AdvisorNode? _teamTree; // Strongly typed mapped model
  BrokerProfileModel? _selectedProfile;
  List<dynamic> _allAdvisors = [];

  AdvisorNode? get teamTree => _teamTree;
  BrokerProfileModel? get selectedProfile => _selectedProfile;
  List<dynamic> get allAdvisors => _allAdvisors;

  Future<void> fetchTeam() async {
    setLoading(true);
    setError(null);
    try {
      _allAdvisors = await repository.getAllAdvisors();
      final data = await repository.getTeamHierarchy();
      if (data is List) {
        // Map the array into a structured Root Node containing the entire network
        _teamTree = AdvisorNode(
          id: 'root',
          name: 'Admin Dashboard',
          role: 'Headquarters',
          code: 'Prarambh Infra',
          avatarUrl: '',
          createdAt: '',
          children: data.map((e) => AdvisorNode.fromJson(e)).toList(),
        );
      } else if (data is Map<String, dynamic>) {
        _teamTree = AdvisorNode.fromJson(data);
        print(_teamTree.toString());
      }
    } catch (e) {
      debugPrint('Fetch Team Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _teamTree = null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchProfile(String advisorId) async {
    setLoading(true);
    setError(null);
    try {
      _selectedProfile = await repository.getBrokerProfile(advisorId);
    } catch (e) {
      debugPrint('Fetch Profile Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _selectedProfile = null;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateAdvisorStatus(String advisorId, String status, String reason) async {
    setLoading(true);
    setError(null);
    try {
      final success = await repository.updateAdvisorStatus(advisorId, status, reason);
      if (success && _selectedProfile != null) {
        // Re-fetch to get updated data
        await fetchProfile(advisorId);
      }
      setLoading(false);
      return success;
    } catch (e) {
      debugPrint('Update Status Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      setLoading(false);
      return false;
    }
  }
}