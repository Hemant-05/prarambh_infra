import 'dart:io';
import '../../../../data/datasources/remote/api_client.dart';
import '../models/advisor_meeting_model.dart';

class AdvisorAttendanceRepository {
  final ApiClient apiClient;

  AdvisorAttendanceRepository({required this.apiClient});

  Future<List<AdvisorMeetingModel>> getAllMeetings() async {
    try {
      final response = await apiClient.getAllMeetings();
      if (response['status'] == true || response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => AdvisorMeetingModel.fromJson(e)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load meetings');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSingleMeeting(String id) async {
    try {
      final response = await apiClient.getSingleMeeting(id);
      if (response['status'] == true || response['status'] == 'success') {
        return response['data']; // Returns the meeting object with Attendance[]
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkIn(String meetingId, String advisorId, File photo) async {
    try {
      final response = await apiClient.checkInAttendance(meetingId, advisorId, photo);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkOut(String meetingId, String advisorId, File photo) async {
    try {
      final response = await apiClient.checkOutAttendance(meetingId, advisorId, photo);
      return response['status'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getDailyAttendance(String date) async {
    try {
      final response = await apiClient.getDailyAttendance(date);
      if (response['status'] == true || response['status'] == 'success') {
        return response['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}