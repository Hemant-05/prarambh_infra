import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_application_model.dart';

class AdminAdvisorRepository {
  final ApiClient apiClient;

  AdminAdvisorRepository({required this.apiClient});

  Future<List<AdvisorApplicationModel>> getAllAdvisors() async {
    try {
      final response = await apiClient.getAllAdvisors();
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AdvisorApplicationModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load advisors');
    } catch (e) {
      rethrow;
    }
  }

  Future<AdvisorApplicationModel> getSingleAdvisor(String id) async {
    try {
      final response = await apiClient.getSingleAdvisor(id);
      if (response['status'] == 'success') {
        return AdvisorApplicationModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load advisor');
    } catch (e) {
      rethrow;
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
    try {
      final response = await apiClient.registerAdvisor(
        fullName, email, phone, designation, fatherName, dob, gender,
        nomineeName, nomineePhone, relationship, occupation, aadhaar, pan,
        bankName, accNumber, ifsc, address, city, state, pincode, leaderCode,
        aadharFront, aadharBack, panPhoto, profilePhoto,
      );
      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approveAdvisor(String advisorId) async {
    try {
      final response = await apiClient.approveAdvisor(advisorId);
      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateAdvisor(String advisorId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.updateAdvisor(advisorId, data);
      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeAdvisorStatus(String advisorId, String status, {String? reason}) async {
    try {
      final response = await apiClient.changeAdvisorStatus(
        advisorId,
        {'status': status, 'reason': reason},
      );
      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAdvisor(String advisorId) async {
    try {
      final response = await apiClient.deleteAdvisor(advisorId);
      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}