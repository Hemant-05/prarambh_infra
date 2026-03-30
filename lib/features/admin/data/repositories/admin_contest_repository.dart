import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/contest_model.dart';

class AdminContestRepository {
  final ApiClient apiClient;
  AdminContestRepository({required this.apiClient});

  Future<List<ContestModel>> getContests() async {
    try {
      final response = await apiClient.getContests();
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((e) => ContestModel.fromJson(e)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load contests');
    } catch (e) { rethrow; }
  }

  Future<ContestModel> getSingleContest(String id) async {
    try {
      final response = await apiClient.getSingleContest(id);
      if (response['status']) {
        return ContestModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load contest');
    } catch (e) { rethrow; }
  }

  Future<bool> addContest({
    required String title, required String startDate, required String endDate,
    required String rewardName, required String rules, required File rewardImage,
  }) async {
    try {
      final response = await apiClient.addContest(
        title, startDate, endDate, rewardName, rules, rewardImage,
      );
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> updateContest(String id, {String? title, File? rewardImage}) async {
    try {
      final response = await apiClient.updateContest(id, title, rewardImage);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> joinContest(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.joinContest(data);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> deleteContest(String id) async {
    try {
      final response = await apiClient.deleteContest(id);
      return response['status'];
    } catch (e) { rethrow; }
  }
}