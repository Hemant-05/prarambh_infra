import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_repository.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/models/admin_dashboard_model.dart';

class AdminProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminRepository adminRepository;

  AdminProvider({required this.adminRepository});

  AdminDashboardModel? _dashboardData;
  int _dashboardIndex = 0;
  String? _selectedProjectId;

  AdminDashboardModel? get dashboardData => _dashboardData;
  String? get selectedProjectId => _selectedProjectId;
  int get dashboardIndex => _dashboardIndex;

  void setDashboardIndex(int index) {
    _dashboardIndex = index;
    notifyListeners();
  }

  void setProjectId(String? id, {bool fetch = true}) {
    _selectedProjectId = id;
    if (fetch) fetchDashboardData(projectId: id);
  }

  Future<void> fetchDashboardData({String? projectId}) async {
    setLoading(true);
    setError(null);
    if (projectId != null) _selectedProjectId = projectId;
    notifyListeners();

    try {
      _dashboardData = await adminRepository.getDashboardData(projectId: _selectedProjectId);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // clearError is provided by ErrorHandlerMixin
}