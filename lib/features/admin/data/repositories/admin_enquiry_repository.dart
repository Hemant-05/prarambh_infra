import '../../../../data/datasources/remote/api_client.dart';
import '../models/enquiry_model.dart';

class AdminEnquiryRepository {
  final ApiClient _apiClient;

  AdminEnquiryRepository(this._apiClient);

  Future<List<AdminEnquiryModel>> getContactEnquiries() async {
    final response = await _apiClient.getContactEnquiries();
    if (response['status'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => AdminEnquiryModel.fromJson(json)).toList();
    }
    throw response['message'] ?? 'Failed to fetch contact enquiries';
  }

  Future<List<AdminCareerEnquiryModel>> getCareerEnquiries({String? status}) async {
    final response = await _apiClient.getCareerEnquiries(status);
    if (response['status'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => AdminCareerEnquiryModel.fromJson(json)).toList();
    }
    throw response['message'] ?? 'Failed to fetch career enquiries';
  }

  Future<bool> deleteContactEnquiry(String id) async {
    final response = await _apiClient.deleteContactEnquiry(id);
    return response['status'] == true;
  }

  Future<bool> deleteCareerEnquiry(String id) async {
    final response = await _apiClient.deleteCareerEnquiry(id);
    return response['status'] == true;
  }
}
