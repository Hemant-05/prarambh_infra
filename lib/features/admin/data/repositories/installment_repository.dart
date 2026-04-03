import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/installment_model.dart';
import '../models/deal_model.dart';

class UpcomingInstallmentRepository {
  final ApiClient apiClient;

  UpcomingInstallmentRepository({required this.apiClient});

  Future<List<UpcomingInstallmentModel>> getUpcomingInstallments({String? advisorCode}) async {
    try {
      final response = await apiClient.getUpcomingInstallments(advisorCode);
      if (response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((json) => UpcomingInstallmentModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load upcoming installments');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markInstallmentAsPaid(int dealId, int installmentIndex) async {
    try {
      // 1. Fetch the full Deal details
      final dealResponse = await apiClient.getSingleDeal(dealId.toString());
      if (dealResponse['status'] != true) throw Exception('Failed to fetch deal details');
      
      final deal = DealModel.fromJson(dealResponse['data']);
      
      // 2. Update the specific installment status in the list
      List<dynamic> updatedInstallments = deal.installments
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
          
      if (installmentIndex >= 0 && installmentIndex < updatedInstallments.length) {
        // Ensure all values are strings to match the working implementation in DealManagementScreen
        updatedInstallments[installmentIndex]['status'] = 'Paid';
        updatedInstallments[installmentIndex]['installment_status'] = 'Paid';
        
        // Also ensure amounts remain as strings as they are in DealManagementScreen
        for (var i = 0; i < updatedInstallments.length; i++) {
          updatedInstallments[i]['amount'] = updatedInstallments[i]['amount'].toString();
        }
      } else {
        throw Exception('Invalid installment index');
      }

      // Calculate overall status like DealManagementScreen does
      int paidCount = updatedInstallments.where((i) => i['status'] == 'Paid').length;
      bool isFullyPaid = updatedInstallments.isNotEmpty && paidCount == updatedInstallments.length;
      String overallStatus = isFullyPaid ? 'Complete' : 'Pending';

      // 3. Update the Deal on the server using FormData (matching AdminDealRepository)
      final Map<String, dynamic> payload = {
        "installments": jsonEncode(updatedInstallments),
        "payment_status": overallStatus, // Using 'Complete'/'Pending' which is standard in this app
      };
      
      final formData = FormData.fromMap(payload);
      final updateResponse = await apiClient.updateDeal(dealId.toString(), formData);
      return updateResponse['status'] == true || updateResponse['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}
