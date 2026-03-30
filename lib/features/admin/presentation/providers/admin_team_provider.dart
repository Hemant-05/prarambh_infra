import 'package:flutter/material.dart';
import '../../data/models/team_models.dart';
import '../../data/repositories/admin_team_repository.dart';

class AdminTeamProvider extends ChangeNotifier {
  final AdminTeamRepository repository;
  AdminTeamProvider({required this.repository});

  dynamic _teamTree; // Can map to AdvisorNode.fromJson in UI
  BrokerProfileModel? _selectedProfile;
  List<dynamic> _allAdvisors = [];
  bool _isLoading = false;

  dynamic get teamTree => _teamTree;
  BrokerProfileModel? get selectedProfile => _selectedProfile;
  List<dynamic> get allAdvisors => _allAdvisors;
  bool get isLoading => _isLoading;

  Future<void> fetchTeam() async {
    _isLoading = true; notifyListeners();
    try {
      _allAdvisors = await repository.getAllAdvisors();
      // Fetches the real tree structure directly from the backend API
      _teamTree = await repository.getTeamHierarchy();
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
}