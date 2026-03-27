import 'package:flutter/material.dart';
import '../../data/models/team_models.dart';
import '../../data/repositories/admin_team_repository.dart';

class AdminTeamProvider extends ChangeNotifier {
  final AdminTeamRepository repository;
  AdminTeamProvider({required this.repository});

  AdvisorNode? _teamTree;
  BrokerProfileModel? _selectedProfile;
  List<dynamic> _allAdvisors = [];
  bool _isLoading = false;

  AdvisorNode? get teamTree => _teamTree;
  BrokerProfileModel? get selectedProfile => _selectedProfile;
  List<dynamic> get allAdvisors => _allAdvisors;
  bool get isLoading => _isLoading;

  /// Fetches all advisors from the API and builds a flat list.
  /// NOTE: The new ApiClient has no team hierarchy/tree endpoint.
  /// The tree structure is built client-side from the flat list.
  Future<void> fetchTeam() async {
    _isLoading = true; notifyListeners();
    try {
      _allAdvisors = await repository.getAllAdvisors();

      // TODO: Build AdvisorNode tree from _allAdvisors using leader_code relationships.
      // For now, keep mock tree for UI rendering.
      _teamTree = AdvisorNode(id: '1', name: 'A (Manager)', role: 'Manager', code: 'M001', avatarUrl: '', children: [
        AdvisorNode(id: '2', name: 'B', role: 'SUP', code: 'SUP01', avatarUrl: '', children: [
          AdvisorNode(id: '5', name: 'E', role: 'ADV', code: 'ADV01', avatarUrl: ''),
          AdvisorNode(id: '6', name: 'F', role: 'ADV', code: 'ADV02', avatarUrl: ''),
        ]),
        AdvisorNode(id: '3', name: 'C', role: 'SUP', code: 'SUP02', avatarUrl: '', children: [
          AdvisorNode(id: '7', name: 'H', role: 'ADV', code: 'ADV03', avatarUrl: ''),
        ]),
        AdvisorNode(id: '4', name: 'D', role: 'SUP', code: 'SUP03', avatarUrl: '', children: [
          AdvisorNode(id: '8', name: 'I', role: 'ADV', code: 'ADV04', avatarUrl: ''),
          AdvisorNode(id: '9', name: 'J', role: 'ADV', code: 'ADV05', avatarUrl: ''),
        ]),
        AdvisorNode(id: '10', name: 'K', role: 'ADV', code: 'ADV06', avatarUrl: ''),
      ]);
    } catch (e) {
      debugPrint('Fetch Team Error: $e');
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
      // Mock fallback for UI testing
      _selectedProfile = BrokerProfileModel(
        id: advisorId, name: 'Rajesh Kumar', code: 'BRK-2023-089',
        phone: '+91 98765 43210', email: 'rajesh.k@example.com',
        age: 34, suspectCount: 12, prospectCount: 8, negotCount: 5,
        dealCount: 3, personalSales: '₹24.5L', teamSales: '₹1.2Cr', status: 'Active',
      );
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}