import 'package:flutter/material.dart';
import '../../data/models/advisor_leaderboard_model.dart';
import '../../data/repositories/advisor_leaderboard_repository.dart';

class AdvisorLeaderboardProvider extends ChangeNotifier {
  final AdvisorLeaderboardRepository repository;

  AdvisorLeaderboardProvider({required this.repository}) {
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  List<AdvisorLeaderboardModel> _advisors = [];
  bool _isLoading = false;
  String _currentTab = 'Sales';
  
  late int _selectedMonth;
  late int _selectedYear;

  List<AdvisorLeaderboardModel> get allAdvisors => _advisors;
  bool get isLoading => _isLoading;
  String get currentTab => _currentTab;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  List<AdvisorLeaderboardModel> get topThree {
    if (_advisors.length < 3) return List.from(_advisors);
    return _advisors.sublist(0, 3);
  }

  List<AdvisorLeaderboardModel> get remainingAdvisors {
    if (_advisors.length <= 3) return [];
    return _advisors.sublist(3);
  }

  void setTab(String tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      _sortAdvisors();
      notifyListeners();
    }
  }

  void setTimeframe(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    fetchLeaderboard();
  }

  void _sortAdvisors() {
    if (_currentTab == 'Sales') {
      _advisors.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    } else if (_currentTab == 'Recruitment') {
      _advisors.sort((a, b) => b.teamSize.compareTo(a.teamSize));
    } else if (_currentTab == 'Attendance') {
      _advisors.sort((a, b) => b.attendancePercentage.compareTo(a.attendancePercentage));
    }
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawData = await repository.getLeaderboard(
        month: _selectedMonth,
        year: _selectedYear,
      );
      
      _advisors = rawData
          .where((a) => 
              a.advisorCode.toLowerCase() != 'admin001' && 
              a.designation.toLowerCase() != 'admin')
          .toList();

      _sortAdvisors();
    } catch (e) {
      debugPrint('Fetch Advisor Leaderboard Error: $e');
      _advisors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
