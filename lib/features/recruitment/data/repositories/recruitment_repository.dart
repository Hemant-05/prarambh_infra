import 'dart:io';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/recruitment_model.dart';

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
    required File aadharFront, required File aadharBack, required File panPhoto,
    required File panBackPhoto, // NEW FIELD
    required File profilePhoto,
  }) async {
    try {
      final response = await apiClient.registerAdvisor(
        fullName, email, phone, designation, fatherName, dob, gender,
        nomineeName, nomineePhone, relationship, occupation, aadhaar, pan,
        bankName, accNumber, ifsc, address, city, state, pincode, leaderCode,
        aadharFront, aadharBack, panPhoto, panBackPhoto, profilePhoto, // Added to client call
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


  Future<RecruitmentDashboardModel> getDashboardData() async {
    try {

      // final response = await apiClient.getRecruitmentDashboard();
      // return RecruitmentDashboardModel.fromJson(response['data']);

      // --- MOCK DATA MATCHING YOUR IMAGE ---
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network loading
      return RecruitmentDashboardModel.fromJson({
        "total_brokers": 124,
        "active_brokers": 98,
        "pending_brokers": 12,
        "suspended_brokers": 4,
        "recent_recruitments": [
          {
            "id": "1",
            "name": "Rahul Sharma",
            "date_joined": "Oct 12, 2023",
            "status": "Active",
            "image_url": "https://i.pravatar.cc/150?img=11"
          },
          {
            "id": "2",
            "name": "Priya Patel",
            "date_joined": "Oct 10, 2023",
            "status": "Pending",
            "image_url": "https://i.pravatar.cc/150?img=5"
          },
          {
            "id": "3",
            "name": "Amit Singh",
            "date_joined": "Oct 09, 2023",
            "status": "Active",
            "image_url": "https://i.pravatar.cc/150?img=12"
          },
          {
            "id": "4",
            "name": "Michael Johns...",
            "date_joined": "Oct 05, 2023",
            "status": "Suspended",
            "image_url": null // Tests the initials avatar fallback
          },
          {
            "id": "5",
            "name": "Anjali Kumar",
            "date_joined": "Oct 04, 2023",
            "status": "Pending",
            "image_url": null
          },
        ]
      });
    } catch (e) {
      rethrow;
    }
  }
}