import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/deal_model.dart';

class AdminDealRepository {
  final ApiClient apiClient;
  AdminDealRepository({required this.apiClient});

  Future<bool> createDeal({
    required String clientName, required String clientNumber,
    required String advisorCode, required String stage,
    required String dealStatus, required String paymentAmount,
    required String paymentMode,
    File? clientAdharFront, File? clientAdharBack,
    File? clientPanFront, File? clientPanBack,
    List<String>? docTitles, List<File>? docFiles,
  }) async {
    try {
      final response = await apiClient.createDeal(
          clientName, clientNumber, advisorCode, stage, dealStatus, paymentAmount, paymentMode,
          clientAdharFront, clientAdharBack, clientPanFront, clientPanBack,
          "[]", "[]", // Empty JSON arrays for notes and installments initially
          docTitles, docFiles
      );
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateDealInstallments(String dealId, String installmentsJson, String totalAmount, String status) async {
    try {
      final response = await apiClient.updateDeal(dealId, {
        "installments": installmentsJson,
        "total_payment_amount": totalAmount,
        "payment_status": status,
      });
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> addDealNote(String dealId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.addDealNote(dealId, data);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<List<DealModel>> getAllDeals() async {
    try {
      final response = await apiClient.getAllDeals();
      if (response['status']) {
        final List data = response['data'] ?? [];
        return data.map((json) => DealModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load deals');
    } catch (e) { rethrow; }
  }

  Future<DealModel> getSingleDeal(String id) async {
    try {
      final response = await apiClient.getSingleDeal(id);
      if (response['status']) {
        return DealModel.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load deal');
    } catch (e) { rethrow; }
  }

  Future<bool> deleteDeal(String id) async {
    try {
      final response = await apiClient.deleteDeal(id);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}