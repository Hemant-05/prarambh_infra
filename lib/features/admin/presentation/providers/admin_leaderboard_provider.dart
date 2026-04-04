import 'package:flutter/material.dart';
import '../../data/models/advisor_rank_model.dart';
import '../../data/repositories/admin_leaderboard_repository.dart';

class AdminLeaderboardProvider extends ChangeNotifier {
  final AdminLeaderboardRepository repository;

  AdminLeaderboardProvider({required this.repository}) {
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  List<AdvisorRankModel> _advisors = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _currentTab = 'Sales Volume';
  
  late int _selectedMonth;
  late int _selectedYear;

  List<AdvisorRankModel> get allAdvisors => _advisors;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get currentTab => _currentTab;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

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

  void setTimeframe(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawAdvisors = await repository.getLeaderboard(
        month: _selectedMonth,
        year: _selectedYear,
      );

      _advisors = rawAdvisors
          .where((a) =>
              a.advisorCode.toLowerCase() != 'admin001' &&
              a.designation.toLowerCase() != 'admin')
          .toList();
      
      // Sort based on tab if needed, but usually the API rank is sufficient.
      // If we want to re-sort locally:
      if (_currentTab == 'Sales Volume') {
        _advisors.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
      } else if (_currentTab == 'Recruitment') {
        _advisors.sort((a, b) => b.teamSize.compareTo(a.teamSize));
      } else if (_currentTab == 'Attendance') {
        _advisors.sort((a, b) => b.attendancePercentage.compareTo(a.attendancePercentage));
      }
      
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