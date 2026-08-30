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

  Future<String?> createContest({
    required String title, required String startDate, required String endDate,
    required String rewardName, required String rules, required File rewardImage,
    required File titleImage,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final id = await repository.addContest(
        title: title, startDate: startDate, endDate: endDate,
        rewardName: rewardName, rules: rules, rewardImage: rewardImage,
        titleImage: titleImage,
      );
      if (id != null) await fetchContests();
      return id;
    } catch (e) {
      debugPrint('Create Contest Error: $e');
      return null;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<void> uploadVideoInBackground(String contestId, File video) async {
    try {
      await repository.apiClient.uploadContestVideo(contestId, video);
      debugPrint('Background video upload completed for contest $contestId');
    } catch (e) {
      debugPrint('Background video upload failed for contest $contestId: $e');
    }
  }

  Future<bool> updateContest(String id, {
    String? title,
    String? startDate,
    String? endDate,
    String? rewardName,
    String? rules,
    String? status,
    File? rewardImage,
    File? titleImage,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateContest(
        id,
        title: title,
        startDate: startDate,
        endDate: endDate,
        rewardName: rewardName,
        rules: rules,
        status: status,
        rewardImage: rewardImage,
        titleImage: titleImage,
      );
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