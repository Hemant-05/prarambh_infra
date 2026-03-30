import 'package:flutter/material.dart';
import '../../data/models/advisor_dashboard_model.dart';
import '../../data/repositories/advisor_repository.dart';

class AdvisorDashboardProvider extends ChangeNotifier {
  final AdvisorRepository repository;
  AdvisorDashboardProvider({required this.repository});

  AdvisorDashboardModel? _data;
  bool _isLoading = false;

  AdvisorDashboardModel? get data => _data;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData(String advisorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await repository.getDashboardData(advisorId);
    } catch (e) {
      debugPrint("Error fetching advisor dashboard: $e");
      _data = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}