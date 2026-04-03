// lib/features/client/data/repositories/client_repository.dart

import 'package:flutter/foundation.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import '../models/blog_model.dart';
import '../models/enquiry_model.dart';

class ClientRepository {
  final ApiClient apiClient;

  ClientRepository({required this.apiClient});

  // Projects & Units
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final response = await apiClient.getAllProjects();
      if (response != null && response['status'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get All Projects Error: $e');
      return [];
    }
  }

  Future<List<UnitModel>> getAllUnits({String? projectId}) async {
    try {
      final response = await apiClient.getUnits(projectId);
      if (response != null && response['status'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => UnitModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get Units Error: $e');
      return [];
    }
  }

  Future<ProjectModel?> getProjectDetails(String id) async {
    try {
      final response = await apiClient.getSingleProject(id);
      if (response != null && response['status'] == true) {
        return ProjectModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Get Project Details Error: $e');
      return null;
    }
  }

  // Blogs & News
  Future<List<BlogModel>> getBlogs() async {
    try {
      final response = await apiClient.getBlogs('Active');
      if (response != null && response['status'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => BlogModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get Blogs Error: $e');
      return [];
    }
  }

  Future<BlogModel?> getSingleBlog(String id) async {
    try {
      final response = await apiClient.getSingleBlog(id);
      if (response != null && response['status'] == true) {
        return BlogModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Get Single Blog Error: $e');
      return null;
    }
  }

  // Enquiries
  Future<bool> addContactEnquiry(ContactRequest enquiry) async {
    try {
      final response = await apiClient.addContactEnquiry(enquiry);
      return response != null && response['status'] == true;
    } catch (e) {
      debugPrint('Add Contact Enquiry Error: $e');
      return false;
    }
  }

  Future<bool> addInterestedLead(InterestedLeadRequest enquiry) async {
    try {
      final response = await apiClient.createInterestedLead(enquiry);
      return response != null && response['status'] == true;
    } catch (e) {
      debugPrint('Add Interested Lead Error: $e');
      return false;
    }
  }

  Future<bool> addCareerEnquiry(CareerEnquiryRequest enquiry) async {
    try {
      final response = await apiClient.addCareerEnquiry(enquiry.toJson());
      return response != null && response['status'] == true;
    } catch (e) {
      debugPrint('Add Career Enquiry Error: $e');
      return false;
    }
  }
}
