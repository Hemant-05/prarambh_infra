import 'dart:io';
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

  Future<void> fetchAdvisors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _advisors = await repository.getAllAdvisors(status: 'pending');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveAdvisor(String advisorId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.approveAdvisor(advisorId);
      if (success) await fetchAdvisors();
      return success;
    } catch (e) {
      debugPrint('Approve Advisor Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> changeAdvisorStatus(String advisorId, String status, {String? reason}) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.changeAdvisorStatus(advisorId, status, reason: reason);
      if (success) await fetchAdvisors();
      return success;
    } catch (e) {
      debugPrint('Change Status Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> registerAdvisor({
    required String fullName,
    required String email,
    required String phone,
    required String designation,
    required String fatherName,
    required String dob,
    required String gender,
    required String nomineeName,
    required String nomineePhone,
    required String relationship,
    required String occupation,
    required String aadhaar,
    required String pan,
    required String bankName,
    required String accNumber,
    required String ifsc,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String leaderCode,
    required File aadharFront,
    required File aadharBack,
    required File panPhoto,
    required File profilePhoto,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.registerAdvisor(
        fullName: fullName, email: email, phone: phone,
        designation: designation, fatherName: fatherName, dob: dob,
        gender: gender, nomineeName: nomineeName, nomineePhone: nomineePhone,
        relationship: relationship, occupation: occupation, aadhaar: aadhaar,
        pan: pan, bankName: bankName, accNumber: accNumber, ifsc: ifsc,
        address: address, city: city, state: state, pincode: pincode,
        leaderCode: leaderCode, aadharFront: aadharFront, aadharBack: aadharBack,
        panPhoto: panPhoto, profilePhoto: profilePhoto,
      );
    } catch (e) {
      debugPrint('Register Advisor Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> deleteAdvisor(String advisorId) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.deleteAdvisor(advisorId);
      if (success) _advisors.removeWhere((a) => a.id == advisorId);
      return success;
    } catch (e) {
      debugPrint('Delete Advisor Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}