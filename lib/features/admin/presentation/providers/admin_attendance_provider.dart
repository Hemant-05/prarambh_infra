import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import '../../data/repositories/admin_attendance_repository.dart';
import '../../data/models/meeting_model.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdminAttendanceProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AdminAttendanceRepository repository;
  AdminAttendanceProvider({required this.repository});

  List<MeetingModel> _meetings = [];
  MeetingModel? _selectedMeeting;
  bool _isSaving = false;

  List<MeetingModel> get meetings => _meetings;
  MeetingModel? get selectedMeeting => _selectedMeeting;
  bool get isSaving => _isSaving;
  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  // Frontend calculation methods for stats
  int get totalMeetingsCount => _meetings.length;
  int get upcomingMeetingsCount =>
      _meetings.where((m) => m.status.toLowerCase() == 'upcoming').length;
  int get completedMeetingsCount =>
      _meetings.where((m) => m.status.toLowerCase() == 'completed').length;
  int get ongoingMeetingsCount =>
      _meetings.where((m) => m.status.toLowerCase() == 'ongoing').length;

  // Keep legacy getter for AttendanceReportScreen compatibility
  dynamic get currentMeeting => _selectedMeeting;

  dynamic _dailyReport;
  dynamic get dailyReport => _dailyReport;

  Future<void> fetchDailyAttendance(String date) async {
    setLoading(true);
    setError(null);
    try {
      _dailyReport = await repository.getDailyAttendance(date);
    } catch (e) {
      debugPrint('Fetch Daily Attendance Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _dailyReport = null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchAllMeetings() async {
    setLoading(true);
    setError(null);
    try {
      final raw = await repository.getAllMeetings();
      if (raw is List) {
        _meetings = raw
            .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
            .toList();
        // Sort newest first
        _meetings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _meetings = [];
      }
    } catch (e) {
      debugPrint('Fetch All Meetings Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      _meetings = [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchMeetingById(String meetingId) async {
    setLoading(true);
    setError(null);
    try {
      final raw = await repository.getSingleMeeting(meetingId);
      if (raw is Map<String, dynamic>) {
        _selectedMeeting = MeetingModel.fromJson(raw);
      }
    } catch (e) {
      debugPrint('Fetch Meeting Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addMeeting(Map<String, dynamic> data) async {
    isSaving = true;
    try {
      final success = await repository.addMeeting(data);
      if (success) await fetchAllMeetings();
      return success;
    } catch (e) {
      debugPrint('Add Meeting Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> deleteMeeting(String id) async {
    isSaving = true;
    try {
      final success = await repository.deleteMeeting(id);
      if (success) _meetings.removeWhere((m) => m.id == id);
      return success;
    } catch (e) {
      debugPrint('Delete Meeting Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }

  Future<bool> completeMeeting(String id) async {
    isSaving = true;
    try {
      final now = DateTime.now();
      final endTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      // mark status as completed and set end_time
      final success = await repository.updateMeeting(id, {'end_time': endTime});
      if (success) await fetchAllMeetings();
      return success;
    } catch (e) {
      debugPrint('Complete Meeting Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      return false;
    } finally {
      isSaving = false;
    }
  }
}
