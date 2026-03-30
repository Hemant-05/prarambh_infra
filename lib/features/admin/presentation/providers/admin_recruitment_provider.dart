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
      final data = await repository.getDashboard();
      _dashboardData = RecruitmentDashboardModel.fromJson(data);
    } catch (e) {
      debugPrint('Fetch Dashboard Error: $e');
      _dashboardData = null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> fetchRecruitsForAdvisor(String advisorId) async {
    _isLoadingDetail = true; notifyListeners();
    try {
      // Using the team tree endpoint to get the specific recruits under this advisor
      final data = await repository.getTeamTree(leaderId: advisorId);
      if (data is List) {
        _currentRecruits = data.map((e) => RecruitedPersonModel.fromJson(e)).toList();
      } else if (data != null && data['children'] != null) {
        _currentRecruits = (data['children'] as List).map((e) => RecruitedPersonModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch Recruits Error: $e');
      _currentRecruits = [];
    } finally {
      _isLoadingDetail = false; notifyListeners();
    }
  }
}