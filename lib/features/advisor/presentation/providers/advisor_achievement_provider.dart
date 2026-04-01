import 'package:flutter/material.dart';
import '../../data/models/achievement_model.dart';
import '../../data/repositories/advisor_achievement_repository.dart';

class AdvisorAchievementProvider extends ChangeNotifier {
  final AdvisorAchievementRepository repository;
  
  AdvisorAchievementProvider({required this.repository});
  
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;
  String? _error;
  String _selectedYear = 'All';
  
  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedYear => _selectedYear;

  List<String> get availableYears {
    final years = _achievements.map((a) => a.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Descending order
    return ['All', ...years];
  }

  List<AchievementModel> get filteredAchievements {
    if (_selectedYear == 'All') return _achievements;
    return _achievements.where((a) => a.year == _selectedYear).toList();
  }

  void selectYear(String year) {
    _selectedYear = year;
    notifyListeners();
  }

  Future<void> fetchAchievements(String advisorCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _achievements = await repository.getAchievements(advisorCode);
      // Reset filter if previous filter doesn't exist in new data
      if (_selectedYear != 'All' && !availableYears.contains(_selectedYear)) {
        _selectedYear = 'All';
      }
    } catch (e) {
      _error = e.toString();
      _achievements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
