import 'dart:io';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/recruitment_model.dart';

class RecruitmentRepository {
  final ApiClient apiClient;
  RecruitmentRepository({required this.apiClient});

  Future<bool> registerAdvisorDetailed({
    required String fullName, required String email, required String phone,
    required String designation, required String fatherName, required String dob,
    required String gender, required String nomineeName, required String nomineeDob,
    required String relationship, required String occupation, required String aadhaar,
    required String pan, required String bankName, required String accNumber,
    required String ifsc, required String address, required String city,
    required String state, required String pincode, required String leaderCode,
    required String advisorType,
    required File aadharFront, required File aadharBack, required File panPhoto,
    required File panBackPhoto, required File profilePhoto,
  }) async {
    try {
      final response = await apiClient.registerAdvisor(
        fullName, email, phone, designation, fatherName, dob, gender,
        nomineeName, nomineeDob, relationship, occupation, aadhaar, pan,
        bankName, accNumber, ifsc, address, city, state, pincode, leaderCode,
        advisorType,
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
}