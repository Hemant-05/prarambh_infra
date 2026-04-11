import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../../data/models/advisor_profile_model.dart';
import '../../data/repositories/advisor_profile_repository.dart';

class AdvisorProfileProvider extends ChangeNotifier {
  final AdvisorProfileRepository repository;

  AdvisorProfileProvider({required this.repository});

  AdvisorProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;

  AdvisorProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  void clearProfile() {
    _profile = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProfile(String advisorId) async {
    _profile = null;
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await repository.getAdvisorProfile(advisorId);
    } catch (e) {
      debugPrint('Fetch Advisor Profile Error: $e');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfileByCode(String code) async {
    _profile = null;
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await repository.getAdvisorByCode(code);
    } catch (e) {
      debugPrint('Fetch Advisor By Code Error: $e');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String id,
    String? fullName,
    String? email,
    String? phone,
    String? fatherName,
    String? dob,
    String? gender,
    String? nomineeName,
    String? nomineePhone,
    String? relationship,
    String? occupation,
    String? aadhaar,
    String? pan,
    String? bankName,
    String? accNumber,
    String? ifsc,
    String? address,
    String? city,
    String? state,
    String? pincode,
    File? profilePhoto,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.updateProfile(
        id: id,
        fullName: fullName,
        email: email,
        phone: phone,
        fatherName: fatherName,
        dob: dob,
        gender: gender,
        nomineeName: nomineeName,
        nomineePhone: nomineePhone,
        relationship: relationship,
        occupation: occupation,
        aadhaar: aadhaar,
        pan: pan,
        bankName: bankName,
        accNumber: accNumber,
        ifsc: ifsc,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        profilePhoto: profilePhoto,
      );
      if (success) {
        await fetchProfile(id); // Refresh profile data
      }
      return success;
    } catch (e) {
      debugPrint('Update Profile Provider Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}