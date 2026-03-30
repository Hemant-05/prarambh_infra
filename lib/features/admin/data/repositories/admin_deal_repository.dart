import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/deal_model.dart';

class AdminDealRepository {
  final ApiClient apiClient;
  AdminDealRepository({required this.apiClient});

  Future<bool> createDeal({
    required String clientName, required String clientNumber,
    required String advisorCode, required String stage,
    required String dealStatus, required String tokenAmount,
    required String tokenPaymentMode,
    File? clientAdharFront, File? clientAdharBack,
    File? clientPanFront, File? clientPanBack,
    List<String>? docTitles, List<File>? docFiles,
  }) async {
    try {
      final response = await apiClient.createDeal(
          clientName, clientNumber, advisorCode, stage, dealStatus, tokenAmount, tokenPaymentMode,
          clientAdharFront, clientAdharBack, clientPanFront, clientPanBack,
          "[]", "[]", // Empty JSON arrays for notes and installments initially
          docTitles, docFiles
      );
      return response['status'] == true || response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<bool> updateDealInstallments({
    required String dealId, 
    required String installmentsJson, 
    required String totalAmount, 
    required String status,
    String? tokenAmount,
    String? tokenPaymentMode,
    String? tokenDate,
    String? paymentPlan,
  }) async {
    try {
      final payload = <String, dynamic>{
        "installments": installmentsJson,
        "payment_status": status,
      };
      // Skip appending if empty
      if (totalAmount.isNotEmpty) payload["payment_amount"] = totalAmount;
      if (paymentPlan != null && paymentPlan.isNotEmpty) payload["payment_plan"] = paymentPlan;
      
      if (tokenAmount != null && tokenAmount.isNotEmpty) {
        payload["token_amount"] = tokenAmount;
        payload["deal_status"] = "verified"; // <-- The requested status update feature!
      }
      if (tokenPaymentMode != null && tokenPaymentMode.isNotEmpty) payload["token_payment_mode"] = tokenPaymentMode;
      if (tokenDate != null && tokenDate.isNotEmpty) payload["token_date"] = tokenDate;
      
      final formData = FormData.fromMap(payload);
      final response = await apiClient.updateDeal(dealId, formData);
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