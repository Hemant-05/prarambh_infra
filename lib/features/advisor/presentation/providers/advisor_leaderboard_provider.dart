import 'package:flutter/material.dart';
import '../../data/models/advisor_leaderboard_model.dart';
import '../../data/repositories/advisor_leaderboard_repository.dart';

class AdvisorLeaderboardProvider extends ChangeNotifier {
  final AdvisorLeaderboardRepository repository;

  AdvisorLeaderboardProvider({required this.repository});

  List<AdvisorLeaderboardModel> _advisors = [];
  bool _isLoading = false;

  List<AdvisorLeaderboardModel> get allAdvisors => _advisors;
  bool get isLoading => _isLoading;

  List<AdvisorLeaderboardModel> get topThree {
    if (_advisors.length < 3) return List.from(_advisors);
    return _advisors.sublist(0, 3);
  }

  List<AdvisorLeaderboardModel> get remainingAdvisors {
    if (_advisors.length <= 3) return [];
    return _advisors.sublist(3);
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawData = await repository.getLeaderboard();
      final filteredData = rawData
          .where((a) => a.advisorCode.toLowerCase() != 'admin001')
          .toList();

      // Sort by total sales descending
      filteredData.sort((a, b) => b.totalSales.compareTo(a.totalSales));
      _advisors = filteredData;
    } catch (e) {
      debugPrint('Fetch Advisor Leaderboard Error: $e');
      _advisors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
