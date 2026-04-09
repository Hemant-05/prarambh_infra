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
    // Return the first one that is not completed
    return todayMeetings.firstWhere((m) => m.status != 'completed', orElse: () => todayMeetings.first);
  }

  Future<void> fetchMeetings(String advisorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Call multiple APIs at the same time
      final results = await Future.wait([
        repository.getAllMeetings(),
        repository.getDailyAttendance(today),
      ]);

      List<AdvisorMeetingModel> allMeetings = results[0] as List<AdvisorMeetingModel>;
      dynamic attendanceData = results[1];

      if (attendanceData != null && attendanceData['present_advisors'] != null) {
        final List presentList = attendanceData['present_advisors'];
        
        // Filter for this specific advisor with relaxed ID mapping
        final myAttendance = presentList.where((a) {
          final aid = a['advisor_id']?.toString();
          final code = a['Advisor_code']?.toString();
          final id = a['id']?.toString();
          return aid == advisorId || code == advisorId || id == advisorId;
        }).toList();

        // Merge attendance into meetings
        _meetings = allMeetings.map((mtg) {
          final att = myAttendance.firstWhere(
            (a) => a['meeting_id']?.toString() == mtg.id,
            orElse: () => null,
          );

          if (att != null) {
            return mtg.copyWith(
              checkInTime: att['check_in_time'],
              checkOutTime: att['check_out_time'],
              // If check-out is done, mark as completed from advisor perspective
              status: att['check_out_time'] != null ? 'completed' : mtg.status,
            );
          }
          return mtg;
        }).toList();
      } else {
        _meetings = allMeetings;
      }
    } catch (e) {
      debugPrint('Fetch Meetings Error: $e');
      _meetings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitAttendance(String meetingId, String advisorId, File photo, bool isCheckIn) async {
    _isSaving = true;
    notifyListeners();
    try {
      bool success = false;
      if (isCheckIn) {
        success = await repository.checkIn(meetingId, advisorId, photo);
      } else {
        success = await repository.checkOut(meetingId, advisorId, photo);
      }
      
      if (success) {
        // OPTIMISTIC UPDATE: Update local state immediately for better UX
        final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final index = _meetings.indexWhere((m) => m.id == meetingId);
        if (index != -1) {
          final current = _meetings[index];
          _meetings[index] = current.copyWith(
            checkInTime: isCheckIn ? nowStr : current.checkInTime,
            checkOutTime: !isCheckIn ? nowStr : current.checkOutTime,
            status: !isCheckIn ? 'completed' : current.status,
          );
          notifyListeners();
        }
        
        // Background refresh to sync official server timestamps
        fetchMeetings(advisorId);
      }
      return success;
    } catch (e) {
      debugPrint('Attendance Submission Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}