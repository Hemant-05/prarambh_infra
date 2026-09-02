import 'dart:io';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/recruitment_model.dart';
import 'package:prarambh_infra/features/admin/data/models/review_message_model.dart';

class RecruitmentRepository {
  final ApiClient apiClient;
  RecruitmentRepository({required this.apiClient});

  Future<bool> registerAdvisorDetailed({
    required String fullName, required String email, required String phone,
    required String designation, required String fatherName, required String dob,
    required String gender, required String nomineeName, required String nomineePhone,
    required String relationship, required String occupation, required String aadhaar,
    required String pan, required String bankName, required String accNumber,
    required String ifsc, required String address, required String city,
    required String state, required String pincode, required String leaderCode,
    required String advisorType,
    // NEW FIELDS
    String? applicationNumber, String? maritalStatus, String? branchCode,
    String? branchLocation, String? headOffice, String? primaryProfession,
    String? qualification, String? nationality, String? referencePerson,
    // FILES
    required File aadharFront, required File aadharBack, required File panPhoto,
    required File panBackPhoto, required File profilePhoto,
  }) async {
    try {
      final response = await apiClient.registerAdvisor(
        fullName, email, phone, designation, fatherName, dob, gender,
        nomineeName, nomineePhone, relationship, occupation, aadhaar, pan,
        bankName, accNumber, ifsc, address, city, state, pincode, leaderCode,
        advisorType,
        applicationNumber, maritalStatus, branchCode, branchLocation, headOffice,
        primaryProfession, qualification, nationality, referencePerson,
        aadharFront, aadharBack, panPhoto, panBackPhoto, profilePhoto,
      );

      final status = response['status'];
      if (status == true || status == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Advisor Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RecruitmentDashboardModel> getDashboardData(String advisorId) async {
    try {
      final response = await apiClient.getAdvisorTeam(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return RecruitmentDashboardModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to fetch team data');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSingleAdvisor(String advisorId) async {
    try {
      final response = await apiClient.getSingleAdvisor(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to fetch advisor details');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateAdvisorDetailed(
    String advisorId, {
    required String fullName, required String email, required String phone,
    required String designation, required String fatherName, required String dob,
    required String gender, required String nomineeName, required String nomineePhone,
    required String relationship, required String occupation, required String aadhaar,
    required String pan, required String bankName, required String accNumber,
    required String ifsc, required String address, required String city,
    required String state, required String pincode, required String leaderCode,
    required String advisorType,
    String? applicationNumber, String? maritalStatus, String? branchCode,
    String? branchLocation, String? headOffice, String? primaryProfession,
    String? qualification, String? nationality, String? referencePerson,
    // File parts are not required for update unless they change, but the update API uses multipart
    File? aadharFront, File? aadharBack, File? panPhoto, File? panBackPhoto, File? profilePhoto,
  }) async {
    try {
      final response = await apiClient.updateAdvisorProfile(
        advisorId, fullName, email, phone, fatherName, dob, gender,
        nomineeName, nomineePhone, relationship, occupation, aadhaar, pan,
        bankName, accNumber, ifsc, address, city, state, pincode,
        null, null, null, null, null, null, null, null, null, null, null, // Omit new fields since update API does not support them
        aadharFront, aadharBack, panPhoto, panBackPhoto, profilePhoto,
      );

      final status = response['status'];
      if (status == true || status == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Advisor Update failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewMessageModel>> getReviewMessages(String advisorId) async {
    try {
      final response = await apiClient.getReviewMessages(advisorId);
      if (response['status'] == true || response['status'] == 'success') {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => ReviewMessageModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to fetch review messages');
    } catch (e) {
      rethrow;
    }
  }
}