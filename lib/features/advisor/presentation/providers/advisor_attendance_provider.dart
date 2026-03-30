import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/advisor_meeting_model.dart';
import '../../data/repositories/advisor_attendance_repository.dart';

class AdvisorAttendanceProvider extends ChangeNotifier {
  final AdvisorAttendanceRepository repository;

  AdvisorAttendanceProvider({required this.repository});

  List<AdvisorMeetingModel> _meetings = [];
  bool _isLoading = false;
  bool _isSaving = false;

  List<AdvisorMeetingModel> get meetings => _meetings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  // Filter meetings by specific date
  List<AdvisorMeetingModel> getMeetingsForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _meetings.where((m) => m.meetingDate == dateStr).toList();
  }

  // Find the closest active meeting for the Blue Card (based on today)
  AdvisorMeetingModel? get activeMeeting {
    final todayMeetings = getMeetingsForDate(DateTime.now());
    if (todayMeetings.isEmpty) return null;
    return todayMeetings.first;
  }

  Future<void> fetchMeetings() async {
    _isLoading = true; notifyListeners();
    try {
      _meetings = await repository.getAllMeetings();
    } catch (e) {
      debugPrint('Fetch Meetings Error: $e');
      _meetings = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> submitAttendance(String meetingId, String advisorId, File photo, bool isCheckIn) async {
    _isSaving = true; notifyListeners();
    try {
      if (isCheckIn) {
        return await repository.checkIn(meetingId, advisorId, photo);
      } else {
        return await repository.checkOut(meetingId, advisorId, photo);
      }
    } catch (e) {
      debugPrint('Attendance Submission Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}