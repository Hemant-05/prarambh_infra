import 'package:flutter/material.dart';
import '../../data/models/team_models.dart';
import '../../data/repositories/admin_team_repository.dart';

class AdminTeamProvider extends ChangeNotifier {
  final AdminTeamRepository repository;
  AdminTeamProvider({required this.repository});

  AdvisorNode? _teamTree;
  BrokerProfileModel? _selectedProfile;
  bool _isLoading = false;

  AdvisorNode? get teamTree => _teamTree;
  BrokerProfileModel? get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchTeam() async {
    _isLoading = true; notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // MOCK DATA: Building the tree structure
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
    } catch (e) { debugPrint(e.toString()); } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchProfile(String id) async {
    _isLoading = true; notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // MOCK DATA for Broker Profile
      _selectedProfile = BrokerProfileModel(
          id: id, name: 'Rajesh Kumar', code: 'BRK-2023-089', phone: '+91 98765 43210',
          email: 'rajesh.k@example.com', age: 34, suspectCount: 12, prospectCount: 8,
          negotCount: 5, dealCount: 3, personalSales: '₹24.5L', teamSales: '₹1.2Cr', status: 'Active'
      );
    } catch (e) { debugPrint(e.toString()); } finally { _isLoading = false; notifyListeners(); }
  }
}