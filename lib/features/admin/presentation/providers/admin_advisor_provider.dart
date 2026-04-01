import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_advisor_repository.dart';
import '../../data/models/advisor_application_model.dart';

class AdminAdvisorProvider extends ChangeNotifier {
  final AdminAdvisorRepository repository;

  AdminAdvisorProvider({required this.repository});

  List<AdvisorApplicationModel> _advisors = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<AdvisorApplicationModel> get advisors => _advisors;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // FIX: Added the ability to pass status dynamically (e.g. 'pending', 'active')
  Future<void> fetchAdvisors({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _advisors = await repository.getAllAdvisors(status: status);
    } catch (e) {
      _errorMessage = e.toString();
      _advisors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveAdvisor(String advisorId) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.approveAdvisor(advisorId);
      if (success) await fetchAdvisors(status: 'pending');
      return success;
    } catch (e) {
      debugPrint('Approve Advisor Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAdvisor(
    String advisorId,
    Map<String, dynamic> data,
  ) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.updateAdvisor(advisorId, data);
      if (success) await fetchAdvisors();
      return success;
    } catch (e) {
      debugPrint('Update Advisor Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changeAdvisorStatus(
    String advisorId,
    String status, {
    String? reason,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.changeAdvisorStatus(
        advisorId,
        status,
        reason: reason,
      );
      if (success) await fetchAdvisors();
      return success;
    } catch (e) {
      debugPrint('Change Status Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAdvisor(String advisorId) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.deleteAdvisor(advisorId);
      if (success) _advisors.removeWhere((a) => a.id == advisorId);
      return success;
    } catch (e) {
      debugPrint('Delete Advisor Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
  Future<AdvisorApplicationModel?> getSingleAdvisor(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await repository.getSingleAdvisor(id);
    } catch (e) {
      debugPrint('Get Single Advisor Error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
