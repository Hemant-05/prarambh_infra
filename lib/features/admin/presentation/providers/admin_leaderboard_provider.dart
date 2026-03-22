import 'package:flutter/material.dart';
import '../../data/models/advisor_rank_model.dart';
import '../../data/repositories/admin_leaderboard_repository.dart';

class AdminLeaderboardProvider extends ChangeNotifier {
  final AdminLeaderboardRepository repository;

  AdminLeaderboardProvider({required this.repository});

  List<AdvisorRankModel> _advisors = [];
  bool _isLoading = false;
  String _currentTab = 'Sales Volume'; // 'Sales Volume' or 'Recruitment'

  List<AdvisorRankModel> get allAdvisors => _advisors;
  bool get isLoading => _isLoading;
  String get currentTab => _currentTab;

  // Helpers to split the data for the UI
  List<AdvisorRankModel> get topThree {
    if (_advisors.length < 3) return _advisors;
    return _advisors.sublist(0, 3);
  }

  List<AdvisorRankModel> get remainingAdvisors {
    if (_advisors.length <= 3) return [];
    return _advisors.sublist(3);
  }

  void setTab(String tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      fetchLeaderboard(tab.toLowerCase().contains('sales') ? 'sales' : 'recruitment');
    }
  }

  Future<void> fetchLeaderboard(String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      // _advisors = await repository.getLeaderboard(type);

      // Mock data matching your screenshot exactly for testing
      await Future.delayed(const Duration(milliseconds: 600)); // Simulate network
      if (type == 'sales') {
        _advisors = [
          AdvisorRankModel(id: '1', name: 'Michael S.', avatarUrl: '', rank: 1, primaryValue: '₹2.5L', secondaryValue: '', trend: '12%', isTrendPositive: true, progress: 1.0),
          AdvisorRankModel(id: '2', name: 'Sarah J.', avatarUrl: '', rank: 2, primaryValue: '₹2.1L', secondaryValue: '', trend: '5%', isTrendPositive: true, progress: 0.8),
          AdvisorRankModel(id: '3', name: 'Jim H.', avatarUrl: '', rank: 3, primaryValue: '₹1.9L', secondaryValue: '', trend: '2%', isTrendPositive: false, progress: 0.7),
          AdvisorRankModel(id: '4', name: 'Dwight S.', avatarUrl: '', rank: 4, primaryValue: '₹1.8L', secondaryValue: '15 Deals', trend: '8%', isTrendPositive: true, progress: 0.65),
          AdvisorRankModel(id: '5', name: 'Andy B.', avatarUrl: '', rank: 5, primaryValue: '₹1.2L', secondaryValue: '10 Deals', trend: '8%', isTrendPositive: true, progress: 0.45),
          AdvisorRankModel(id: '6', name: 'Pam B.', avatarUrl: '', rank: 6, primaryValue: '₹0.95L', secondaryValue: '8 Deals', trend: '4%', isTrendPositive: false, progress: 0.35),
          AdvisorRankModel(id: '7', name: 'Oscar M.', avatarUrl: '', rank: 7, primaryValue: '₹0.82L', secondaryValue: '7 Deals', trend: '2%', isTrendPositive: true, progress: 0.30),
        ];
      } else {
        _advisors = []; // Add mock data for recruitment here
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}