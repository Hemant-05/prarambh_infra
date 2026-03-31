import 'package:flutter/material.dart';
import '../../data/models/recruitment_model.dart';
import '../../data/repositories/recruitment_repository.dart';

class RecruitmentProvider extends ChangeNotifier {
  final RecruitmentRepository repository;
  RecruitmentProvider({required this.repository});

  RecruitmentDashboardModel? _data;
  bool _isLoading = false;

  RecruitmentDashboardModel? get data => _data;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboard(String advisorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await repository.getDashboardData(advisorId);
    } catch (e) {
      debugPrint("Error fetching recruitment dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}