import 'package:flutter/material.dart';
import '../../data/models/team_models.dart';
import '../../data/repositories/admin_team_repository.dart';

class AdminTeamProvider extends ChangeNotifier {
  final AdminTeamRepository repository;
  AdminTeamProvider({required this.repository});

  AdvisorNode? _teamTree; // Strongly typed mapped model
  BrokerProfileModel? _selectedProfile;
  List<dynamic> _allAdvisors = [];
  bool _isLoading = false;

  AdvisorNode? get teamTree => _teamTree;
  BrokerProfileModel? get selectedProfile => _selectedProfile;
  List<dynamic> get allAdvisors => _allAdvisors;
  bool get isLoading => _isLoading;

  Future<void> fetchTeam() async {
    _isLoading = true; notifyListeners();
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
          children: data.map((e) => AdvisorNode.fromJson(e)).toList(),
        );
      } else if (data is Map<String, dynamic>) {
        _teamTree = AdvisorNode.fromJson(data);
      }
    } catch (e) {
      debugPrint('Fetch Team Error: $e');
      _teamTree = null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> fetchProfile(String advisorId) async {
    _isLoading = true; notifyListeners();
    try {
      _selectedProfile = await repository.getBrokerProfile(advisorId);
    } catch (e) {
      debugPrint('Fetch Profile Error: $e');
      _selectedProfile = null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> updateAdvisorStatus(String advisorId, String status, String reason) async {
    try {
      final success = await repository.updateAdvisorStatus(advisorId, status, reason);
      if (success && _selectedProfile != null) {
        // Re-fetch to get updated data
        await fetchProfile(advisorId);
      }
      return success;
    } catch (e) {
      debugPrint('Update Status Error: $e');
      return false;
    }
  }
}