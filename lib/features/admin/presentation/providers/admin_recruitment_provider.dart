import 'package:flutter/material.dart';
import '../../data/models/recruitment_model.dart';
import '../../data/repositories/admin_recruitment_repository.dart';

class AdminRecruitmentProvider extends ChangeNotifier {
  final AdminRecruitmentRepository repository;

  AdminRecruitmentProvider({required this.repository});

  RecruitmentDashboardModel? _dashboardData;
  List<RecruitedPersonModel> _currentRecruits = [];
  bool _isLoading = false;
  bool _isLoadingDetail = false;

  RecruitmentDashboardModel? get dashboardData => _dashboardData;
  List<RecruitedPersonModel> get currentRecruits => _currentRecruits;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;

  /// NOTE: No dedicated recruitment dashboard endpoint exists in the new ApiClient.
  /// Showing mock data. Replace with composing from getAllAdvisors() + getLeaderboard()
  /// once backend provides a combined endpoint.
  Future<void> fetchDashboard() async {
    _isLoading = true; notifyListeners();
    try {
      // TODO: Replace mock with real API calls when backend exposes endpoint.
      await Future.delayed(const Duration(milliseconds: 600));
      _dashboardData = RecruitmentDashboardModel(
        totalBrokers: 124, activeBrokers: 98, pendingVerification: 12, suspendedActionReq: 4,
        topRecruiters: [
          RecruiterModel(id: '1', name: 'Rahul Sharma', joinedDate: 'Joined Oct 12, 2023', recruitCount: 15, initials: 'RS'),
          RecruiterModel(id: '2', name: 'Priya Patel', joinedDate: 'Joined Oct 10, 2023', recruitCount: 8, initials: 'PP'),
          RecruiterModel(id: '3', name: 'Amit Singh', joinedDate: 'Joined Oct 09, 2023', recruitCount: 5, initials: 'AS'),
          RecruiterModel(id: '4', name: 'Michael Johns...', joinedDate: 'Joined Oct 05, 2023', recruitCount: 3, initials: 'MJ'),
        ],
      );
    } catch (e) { debugPrint('Fetch Dashboard Error: $e'); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchRecruitsForAdvisor(String advisorId) async {
    _isLoadingDetail = true; notifyListeners();
    try {
      _currentRecruits = await repository.getRecruitsByAdvisor(advisorId);
    } catch (e) {
      debugPrint('Fetch Recruits Error: $e');
      // Mock data for the drill-down screen
      _currentRecruits = [
        RecruitedPersonModel(id: '101', name: 'Vikas Dubey', joinedDate: 'Joined Nov 01, 2023', status: 'Active', initials: 'VD'),
        RecruitedPersonModel(id: '102', name: 'Neha Gupta', joinedDate: 'Joined Nov 05, 2023', status: 'Pending', initials: 'NG'),
        RecruitedPersonModel(id: '103', name: 'Rohan Mehra', joinedDate: 'Joined Nov 12, 2023', status: 'Active', initials: 'RM'),
      ];
    }
    finally { _isLoadingDetail = false; notifyListeners(); }
  }
}