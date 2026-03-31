import 'package:flutter/material.dart';
import '../../data/models/advisor_team_model.dart';
import '../../data/repositories/advisor_team_repository.dart';

class AdvisorTeamProvider extends ChangeNotifier {
  final AdvisorTeamRepository repository;

  AdvisorTeamProvider({required this.repository});

  AdvisorTeamNode? _teamTree;
  bool _isLoading = false;

  AdvisorTeamNode? get teamTree => _teamTree;
  bool get isLoading => _isLoading;

  Future<void> fetchTeamTree(String leaderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _teamTree = await repository.getTeamTree(leaderId);
    } catch (e) {
      debugPrint('Fetch Advisor Team Tree Error: $e');
      _teamTree = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}