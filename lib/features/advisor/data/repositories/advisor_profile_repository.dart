import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_profile_model.dart';

class AdvisorProfileRepository {
  final ApiClient apiClient;

  AdvisorProfileRepository({required this.apiClient});

  Future<AdvisorProfileModel> getAdvisorProfile(String advisorId) async {
    try {
      final response = await apiClient.getAdvisorProfile(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return AdvisorProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load profile details');
    } catch (e) {
      rethrow;
    }
  }

  Future<AdvisorProfileModel> getAdvisorByCode(String code) async {
    try {
      final response = await apiClient.getAdvisorByCode(code);
      if (response['status'] == true || response['status'] == 'success') {
        return AdvisorProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor by code');
    } catch (e) {
      rethrow;
    }
  }

  Future<AdvisorProfileModel> getSingleAdvisor(String id) async {
    try {
      final response = await apiClient.getSingleAdvisor(id);
      if (response['status']) {
        return AdvisorProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor');
    } catch (e) {
      rethrow;
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
    try {
      final response = await apiClient.updateAdvisorProfile(
        id, fullName, email, phone, fatherName, dob, gender,
        nomineeName, nomineePhone, relationship, occupation,
        aadhaar, pan, bankName, accNumber, ifsc,
        address, city, state, pincode, profilePhoto,
      );
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      debugPrint('Update Profile Repository Error: $e');
      return false;
    }
  }
}