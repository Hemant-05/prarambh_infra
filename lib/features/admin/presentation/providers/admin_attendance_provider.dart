import 'package:flutter/material.dart';
import '../../data/repositories/admin_attendance_repository.dart';
import '../../data/models/meeting_model.dart';

class AdminAttendanceProvider extends ChangeNotifier {
  final AdminAttendanceRepository repository;
  AdminAttendanceProvider({required this.repository});

  List<MeetingModel> _meetings = [];
  MeetingModel? _selectedMeeting;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<MeetingModel> get meetings => _meetings;
  MeetingModel? get selectedMeeting => _selectedMeeting;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // Keep legacy getter for AttendanceReportScreen compatibility
  dynamic get currentMeeting => _selectedMeeting;

  dynamic _dailyReport;
  dynamic get dailyReport => _dailyReport;

  Future<void> fetchDailyAttendance(String date) async {
    _isLoading = true; notifyListeners();
    try {
      _dailyReport = await repository.getDailyAttendance(date);
    } catch (e) {
      debugPrint('Fetch Daily Attendance Error: $e');
      _dailyReport = null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> fetchAllMeetings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await repository.getAllMeetings();
      if (raw is List) {
        _meetings = raw.map((e) => MeetingModel.fromJson(e as Map<String, dynamic>)).toList();
        // Sort newest first
        _meetings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _meetings = [];
      }
    } catch (e) {
      debugPrint('Fetch All Meetings Error: $e');
      _error = e.toString();
      _meetings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMeeting(String meetingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await repository.getSingleMeeting(meetingId);
      if (raw is Map<String, dynamic>) {
        _selectedMeeting = MeetingModel.fromJson(raw);
      }
    } catch (e) {
      debugPrint('Fetch Meeting Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMeeting(Map<String, dynamic> data) async {
    _isSaving = true;
    notifyListeners();
    try {
      final success = await repository.addMeeting(data);
      if (success) await fetchAllMeetings();
      return success;
    } catch (e) {
      debugPrint('Add Meeting Error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMeeting(String id) async {
    try {
      final success = await repository.deleteMeeting(id);
      if (success) _meetings.removeWhere((m) => m.id == id);
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Delete Meeting Error: $e');
      return false;
    }
  }
}
