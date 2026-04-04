import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/models/recruitment_model.dart';
import '../../data/repositories/admin_recruitment_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdminRecruitmentProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminRecruitmentRepository repository;

  AdminRecruitmentProvider({required this.repository});

  RecruitmentDashboardModel? _dashboardData;
  List<RecruitedPersonModel> _currentRecruits = [];
  bool _isLoadingDetail = false;

  RecruitmentDashboardModel? get dashboardData => _dashboardData;
  List<RecruitedPersonModel> get currentRecruits => _currentRecruits;
  bool get isLoadingDetail => _isLoadingDetail;
  set isLoadingDetail(bool value) {
    _isLoadingDetail = value;
    notifyListeners();
  }

  Future<void> fetchDashboard() async {
    setLoading(true);
    setError(null);
    try {
      final data = await repository.getDashboard();
      _dashboardData = RecruitmentDashboardModel.fromJson(data);
    } catch (e) {
      debugPrint('Fetch Dashboard Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _dashboardData = null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchRecruitsForAdvisor(String advisorId) async {
    isLoadingDetail = true;
    setError(null);
    try {
      // Using the team tree endpoint to get the specific recruits under this advisor
      final data = await repository.getTeamTree(leaderId: advisorId);
      if (data is List) {
        _currentRecruits = data
            .map((e) => RecruitedPersonModel.fromJson(e))
            .where((m) =>
                m.advisorCode.toLowerCase() != 'admin001' &&
                m.designation.toLowerCase() != 'admin')
            .toList();
      } else if (data != null && data['children'] != null) {
        _currentRecruits = (data['children'] as List)
            .map((e) => RecruitedPersonModel.fromJson(e))
            .where((m) =>
                m.advisorCode.toLowerCase() != 'admin001' &&
                m.designation.toLowerCase() != 'admin')
            .toList();
      }
    } catch (e) {
      debugPrint('Fetch Recruits Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _currentRecruits = [];
    } finally {
      isLoadingDetail = false;
    }
  }
}