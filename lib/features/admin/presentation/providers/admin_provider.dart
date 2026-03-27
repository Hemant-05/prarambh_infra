import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_repository.dart';
import '../../data/models/admin_dashboard_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository adminRepository;

  AdminProvider({required this.adminRepository});

  AdminDashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// NOTE: The new ApiClient does not expose a dedicated /dashboard endpoint.
  /// Dashboard data must be composed from getAllProjects(), getLeads(),
  /// getAllAdvisors(), and getLeaderboard() via their respective providers.
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Compose dashboard from individual endpoint providers once
      // the backend exposes a combined endpoint, or compose here from
      // AdminProjectProvider, AdminLeadProvider, etc.
      throw UnimplementedError(
        'No /dashboard endpoint in new ApiClient. Compose from individual providers.',
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}