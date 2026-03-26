import '../../../../data/datasources/remote/api_client.dart';
import '../models/attendance_model.dart';

class AdminAttendanceRepository {
  final ApiClient apiClient;
  AdminAttendanceRepository({required this.apiClient});

  Future<bool> createMeeting(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.createMeeting(data);
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }

  Future<List<AttendanceModel>> getAttendanceReport(int userId) async {
    try {
      final response = await apiClient.getAttendance(userId);
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }
}