import 'package:flutter/material.dart';
import '../../data/models/advisor_rank_model.dart';
import '../../data/repositories/admin_leaderboard_repository.dart';

class AdminLeaderboardProvider extends ChangeNotifier {
  final AdminLeaderboardRepository repository;

  AdminLeaderboardProvider({required this.repository});

  List<AdvisorRankModel> _advisors = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _currentTab = 'Sales Volume';

  List<AdvisorRankModel> get allAdvisors => _advisors;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get currentTab => _currentTab;

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
      fetchLeaderboard();
    }
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _advisors = await repository.getLeaderboard();
    } catch (e) {
      debugPrint('Fetch Leaderboard Error: $e');
      _advisors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> evaluateLevel(String advisorId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.evaluateLevel(advisorId);
      if (success) await fetchLeaderboard();
      return success;
    } catch (e) {
      debugPrint('Evaluate Level Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}