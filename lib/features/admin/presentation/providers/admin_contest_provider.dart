import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/contest_model.dart';
import '../../data/repositories/admin_contest_repository.dart';

class AdminContestProvider extends ChangeNotifier {
  final AdminContestRepository repository;
  AdminContestProvider({required this.repository});

  List<ContestModel> _contests = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<ContestModel> get contests => _contests;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> fetchContests() async {
    _isLoading = true; notifyListeners();
    try {
      _contests = await repository.getContests();
    } catch (e) {
      debugPrint('Fetch Contests Error: $e');
      _contests = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> createContest({
    required String title, required String startDate, required String endDate,
    required String rewardName, required String rules, required File rewardImage,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addContest(
        title: title, startDate: startDate, endDate: endDate,
        rewardName: rewardName, rules: rules, rewardImage: rewardImage,
      );
      if (success) await fetchContests();
      return success;
    } catch (e) {
      debugPrint('Create Contest Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> updateContest(String id, {String? title, File? rewardImage}) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateContest(id, title: title, rewardImage: rewardImage);
      if (success) await fetchContests();
      return success;
    } catch (e) {
      debugPrint('Update Contest Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> deleteContest(String id) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.deleteContest(id);
      if (success) _contests.removeWhere((c) => c.id == id);
      return success;
    } catch (e) {
      debugPrint('Delete Contest Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> joinContest(Map<String, dynamic> data) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.joinContest(data);
    } catch (e) {
      debugPrint('Join Contest Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}