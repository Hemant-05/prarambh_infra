import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/attendance_model.dart';

class AdminAttendanceRepository {
  final ApiClient apiClient;
  AdminAttendanceRepository({required this.apiClient});

  Future<bool> addMeeting(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.addMeeting(data);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<dynamic> getSingleMeeting(String meetingId) async {
    try {
      final response = await apiClient.getSingleMeeting(meetingId);
      if (response['status']) {
        return response['data'];
      }
      throw Exception(response['message']);
    } catch (e) { rethrow; }
  }

  Future<bool> checkInAttendance({
    required String meetingId,
    required String advisorId,
    required File photo,
  }) async {
    try {
      final response = await apiClient.checkInAttendance(meetingId, advisorId, photo);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<bool> checkOutAttendance({
    required String meetingId,
    required String advisorId,
    required File photo,
  }) async {
    try {
      final response = await apiClient.checkOutAttendance(meetingId, advisorId, photo);
      return response['status'];
    } catch (e) { rethrow; }
  }

  Future<List<AttendanceModel>> getAttendanceReport() async {
    // NOTE: The new ApiClient has no dedicated getAttendance endpoint.
    // Attendance data is retrieved per-meeting via getSingleMeeting.
    // Returning empty list as a safe fallback until backend provides an endpoint.
    return [];
  }
}