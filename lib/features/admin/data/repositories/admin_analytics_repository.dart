import '../../../../data/datasources/remote/api_client.dart';
import '../models/sales_analytics_model.dart';

class AdminAnalyticsRepository {
  final ApiClient apiClient;

  AdminAnalyticsRepository({required this.apiClient});

  Future<SalesAnalyticsModel> getSalesAnalytics({String? projectId}) async {
    try {
      final dynamic response = await apiClient.getAdminSalesAnalytics(
        projectId,
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected a JSON object');
      }

      if (response['status'] == true || response['status'] == 'success') {
        return SalesAnalyticsModel.fromJson(response['data'] ?? {});
      }
      throw Exception(response['message'] ?? 'Failed to load sales analytics');
    } catch (e) {
      rethrow;
    }
  }
}
