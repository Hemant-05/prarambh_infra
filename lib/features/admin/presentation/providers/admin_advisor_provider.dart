import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_advisor_repository.dart';
import '../../data/models/advisor_application_model.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdminAdvisorProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminAdvisorRepository repository;

  AdminAdvisorProvider({required this.repository});

  List<AdvisorApplicationModel> _advisors = [];
  bool _isSaving = false;

  List<AdvisorApplicationModel> get advisors => _advisors;
  bool get isSaving => _isSaving;
  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  // FIX: Added the ability to pass status dynamically (e.g. 'pending', 'active')
  Future<void> fetchAdvisors({String? status}) async {
    setLoading(true);
    setError(null);

    try {
      _advisors = await repository.getAllAdvisors(status: status);
    } catch (e) {
      debugPrint('Fetch Advisors Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _advisors = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> approveAdvisor(String advisorId) async {
    isSaving = true;
    try {
      final success = await repository.approveAdvisor(advisorId);
      if (success) await fetchAdvisors(status: 'pending');
      return success;
    } catch (e) {
      debugPrint('Approve Advisor Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> updateAdvisor(
    String advisorId,
    Map<String, dynamic> data,
  ) async {
    isSaving = true;
    try {
      final success = await repository.updateAdvisor(advisorId, data);
      if (success) await fetchAdvisors(status: 'pending');
      return success;
    } catch (e) {
      debugPrint('Update Advisor Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> changeAdvisorStatus(
    String advisorId,
    String status, {
    String? reason,
  }) async {
    isSaving = true;
    try {
      final success = await repository.changeAdvisorStatus(
        advisorId,
        status,
        reason: reason,
      );
      if (success) await fetchAdvisors(status: 'pending');
      return success;
    } catch (e) {
      debugPrint('Change Status Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> deleteAdvisor(String advisorId) async {
    isSaving = true;
    try {
      final success = await repository.deleteAdvisor(advisorId);
      if (success) _advisors.removeWhere((a) => a.id == advisorId);
      return success;
    } catch (e) {
      debugPrint('Delete Advisor Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }
  Future<AdvisorApplicationModel?> getSingleAdvisor(String id) async {
    setLoading(true);
    try {
      return await repository.getSingleAdvisor(id);
    } catch (e) {
      debugPrint('Get Single Advisor Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return null;
    } finally {
      setLoading(false);
    }
  }

}
