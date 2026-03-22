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

  Future<List<AttendanceModel>> getAttendanceReport(String meetingId) async {
    try {
      final response = await apiClient.getAttendanceReport(meetingId);
      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load report');
    } catch (e) { rethrow; }
  }

  Future<bool> verifyAttendance(String attendanceId, String status, {String? reason}) async {
    try {
      final response = await apiClient.verifyAttendance({
        "attendance_id": attendanceId, "status": status, "reason": reason ?? ""
      });
      return response['status'] == 'success';
    } catch (e) { rethrow; }
  }
}