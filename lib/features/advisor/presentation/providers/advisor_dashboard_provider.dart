import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/models/advisor_dashboard_model.dart';
import '../../data/repositories/advisor_repository.dart';

class AdvisorDashboardProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdvisorRepository repository;
  AdvisorDashboardProvider({required this.repository});

  AdvisorDashboardModel? _data;
  AdvisorDashboardModel? get data => _data;

  Future<void> fetchDashboardData(String advisorId) async {
    setLoading(true);
    setError(null);

    try {
      _data = await repository.getDashboardData(advisorId);
    } catch (e) {
      debugPrint("Error fetching advisor dashboard: $e");
      setError(e.toString());
      _data = null;
    } finally {
      setLoading(false);
    }
  }
}