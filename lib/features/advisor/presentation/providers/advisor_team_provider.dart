import 'package:flutter/material.dart';
import '../../data/models/advisor_team_model.dart';
import '../../data/models/advisor_performance_model.dart';
import '../../data/models/team_activity_model.dart';
import '../../data/repositories/advisor_team_repository.dart';

class AdvisorTeamProvider extends ChangeNotifier {
  final AdvisorTeamRepository repository;

  AdvisorTeamProvider({required this.repository});

  AdvisorTeamNode? _teamTree;
  AdvisorPerformanceModel? _performanceData;
  TeamActivityModel? _activityData;
  bool _isLoading = false;
  String? _errorMessage;

  AdvisorTeamNode? get teamTree => _teamTree;
  AdvisorPerformanceModel? get performanceData => _performanceData;
  TeamActivityModel? get activityData => _activityData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchTeamTree(String leaderId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _teamTree = await repository.getTeamTree(leaderId);
    } catch (e) {
      debugPrint('Fetch Advisor Team Tree Error: $e');
      _errorMessage = e.toString();
      _teamTree = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPerformance(String advisorId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _performanceData = await repository.getAdvisorPerformance(advisorId);
    } catch (e) {
      debugPrint('Fetch Performance Error: $e');
      _errorMessage = e.toString();
      _performanceData = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTeamActivity(String advisorCode, {int? month, int? year}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _activityData = await repository.getTeamActivity(advisorCode, month: month, year: year);
    } catch (e) {
      debugPrint('Fetch Team Activity Error: $e');
      _errorMessage = e.toString();
      _activityData = null;
    } finally {
      _setLoading(false);
    }
  }
}