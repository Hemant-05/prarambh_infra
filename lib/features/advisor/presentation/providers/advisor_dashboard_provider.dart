import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/models/advisor_dashboard_model.dart';
import '../../data/models/resale_unit_model.dart';
import '../../data/repositories/advisor_repository.dart';

class AdvisorDashboardProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdvisorRepository repository;
  AdvisorDashboardProvider({required this.repository});

  AdvisorDashboardModel? _data;
  AdvisorDashboardModel? get data => _data;

  List<ResaleUnitModel> _resaleUnits = [];
  List<ResaleUnitModel> get resaleUnits => _resaleUnits;

  bool _isLoadingResale = false;
  bool get isLoadingResale => _isLoadingResale;

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

    // Fetch resale units in parallel
    fetchResaleUnits();
  }

  Future<void> fetchResaleUnits() async {
    _isLoadingResale = true;
    notifyListeners();
    try {
      _resaleUnits = await repository.getResaleUnits();
    } catch (e) {
      debugPrint("Error fetching resale units: $e");
      _resaleUnits = [];
    } finally {
      _isLoadingResale = false;
      notifyListeners();
    }
  }
}