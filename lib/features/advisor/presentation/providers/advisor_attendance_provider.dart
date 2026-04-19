import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/advisor_meeting_model.dart';
import '../../data/models/advisor_attendance_history_model.dart';
import '../../data/repositories/advisor_attendance_repository.dart';

class AdvisorAttendanceProvider extends ChangeNotifier {
  final AdvisorAttendanceRepository repository;

  AdvisorAttendanceProvider({required this.repository});

  List<AdvisorMeetingModel> _meetings = [];
  AdvisorAttendanceHistoryModel? _history;
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isSaving = false;

  List<AdvisorMeetingModel> get meetings => _meetings;
  AdvisorAttendanceHistoryModel? get history => _history;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSaving => _isSaving;

  int? _initialMeetingTabIndex;
  int? get initialMeetingTabIndex => _initialMeetingTabIndex;

  void setMeetingTab(int index) {
    _initialMeetingTabIndex = index;
    notifyListeners();
  }

  void clearInitialMeetingTab() {
    _initialMeetingTabIndex = null;
  }

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

  Future<void> fetchMeetings(String advisorId, {DateTime? date}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      
      // Use the new optimized single API call
      _meetings = await repository.getDailyMeetings(dateStr, advisorId);
    } catch (e) {
      debugPrint('Fetch Meetings Error: $e');
      _meetings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceHistory(String advisorId) async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      _history = await repository.getAttendanceHistory(advisorId);
    } catch (e) {
      debugPrint('Fetch History Error: $e');
      _history = null;
    } finally {
      _isLoadingHistory = false;
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