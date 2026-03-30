import 'package:flutter/material.dart';
import '../../../admin/data/models/contest_model.dart';
import '../../data/repositories/advisor_contest_repository.dart';

class AdvisorContestProvider extends ChangeNotifier {
  final AdvisorContestRepository repository;

  AdvisorContestProvider({required this.repository});

  List<ContestModel> _contests = [];
  bool _isLoading = false;
  bool _isJoining = false;

  List<ContestModel> get contests => _contests;
  bool get isLoading => _isLoading;
  bool get isJoining => _isJoining;

  Future<void> fetchContests() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contests = await repository.getContests();
    } catch (e) {
      debugPrint('Fetch Advisor Contests Error: $e');
      _contests = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinContest(String contestId, String advisorCode) async {
    _isJoining = true;
    notifyListeners();
    try {
      final success = await repository.joinContest(contestId, advisorCode);
      if (success) {
        // Refresh to get updated 'isJoined' status
        await fetchContests();
      }
      return success;
    } catch (e) {
      debugPrint('Join Contest Error: $e');
      return false;
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }
}