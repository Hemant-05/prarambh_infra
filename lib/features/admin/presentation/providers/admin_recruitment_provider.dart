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

  Future<void> fetchDashboard() async {
    _isLoading = true; notifyListeners();
    try {
      // _dashboardData = await repository.getDashboard();

      // Mock Data matching your modified requirements
      await Future.delayed(const Duration(milliseconds: 600));
      _dashboardData = RecruitmentDashboardModel(
          totalBrokers: 124, activeBrokers: 98, pendingVerification: 12, suspendedActionReq: 4,
          topRecruiters: [
            RecruiterModel(id: '1', name: 'Rahul Sharma', joinedDate: 'Joined Oct 12, 2023', recruitCount: 15, initials: 'RS'),
            RecruiterModel(id: '2', name: 'Priya Patel', joinedDate: 'Joined Oct 10, 2023', recruitCount: 8, initials: 'PP'),
            RecruiterModel(id: '3', name: 'Amit Singh', joinedDate: 'Joined Oct 09, 2023', recruitCount: 5, initials: 'AS'),
            RecruiterModel(id: '4', name: 'Michael Johns...', joinedDate: 'Joined Oct 05, 2023', recruitCount: 3, initials: 'MJ'),
          ]
      );
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> fetchRecruitsForAdvisor(String advisorId) async {
    _isLoadingDetail = true; notifyListeners();
    try {
      // _currentRecruits = await repository.getRecruitsByAdvisor(advisorId);

      // Mock Data for the drill-down screen
      await Future.delayed(const Duration(milliseconds: 400));
      _currentRecruits = [
        RecruitedPersonModel(id: '101', name: 'Vikas Dubey', joinedDate: 'Joined Nov 01, 2023', status: 'Active', initials: 'VD'),
        RecruitedPersonModel(id: '102', name: 'Neha Gupta', joinedDate: 'Joined Nov 05, 2023', status: 'Pending', initials: 'NG'),
        RecruitedPersonModel(id: '103', name: 'Rohan Mehra', joinedDate: 'Joined Nov 12, 2023', status: 'Active', initials: 'RM'),
      ];
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoadingDetail = false; notifyListeners(); }
  }
}