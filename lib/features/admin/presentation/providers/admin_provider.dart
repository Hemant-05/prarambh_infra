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

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await adminRepository.getDashboardData();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}