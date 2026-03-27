import '../../../../data/datasources/remote/api_client.dart';
import '../models/team_models.dart';

class AdminTeamRepository {
  final ApiClient apiClient;
  AdminTeamRepository({required this.apiClient});

  /// Fetch a single advisor's full profile to represent as a broker/team profile.
  Future<BrokerProfileModel> getBrokerProfile(String advisorId) async {
    try {
      final response = await apiClient.getSingleAdvisor(advisorId);
      if (response['status'] == 'success') {
        return BrokerProfileModel.fromJson(response['data']);
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  /// Fetch all advisors to build a team list view.
  Future<List<dynamic>> getAllAdvisors() async {
    try {
      final response = await apiClient.getAllAdvisors();
      if (response['status'] == 'success') {
        return response['data'] ?? [];
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  /// NOTE: The new ApiClient has no team hierarchy / tree endpoint.
  /// Use getAllAdvisors() and build the hierarchy on the client side.
  Future<AdvisorNode> getTeamHierarchy(String adminId) async {
    throw UnimplementedError(
      'No team hierarchy endpoint exists in the new ApiClient. '
      'Build the hierarchy client-side from getAllAdvisors().',
    );
  }
}