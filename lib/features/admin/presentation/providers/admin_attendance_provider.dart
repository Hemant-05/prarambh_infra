import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/admin_attendance_repository.dart';

class AdminAttendanceProvider extends ChangeNotifier {
  final AdminAttendanceRepository repository;
  AdminAttendanceProvider({required this.repository});

  List<dynamic> _meetings = [];
  bool _isLoading = false;
  bool _isSaving = false;
  dynamic _currentMeeting;

  List<dynamic> get meetings => _meetings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  dynamic get currentMeeting => _currentMeeting;

  Future<void> fetchAllMeetings() async {
    _isLoading = true; notifyListeners();
    try {
      _meetings = await repository.getAllMeetings();
    } catch (e) {
      debugPrint('Fetch All Meetings Error: $e');
      _meetings = [];
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> fetchMeeting(String meetingId) async {
    _isLoading = true; notifyListeners();
    try {
      _currentMeeting = await repository.getSingleMeeting(meetingId);
    } catch (e) {
      debugPrint('Fetch Meeting Error: $e');
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> addMeeting(Map<String, dynamic> data) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.addMeeting(data);
      if (success) await fetchAllMeetings();
      return success;
    } catch (e) {
      debugPrint('Add Meeting Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> checkIn({required String meetingId, required String advisorId, required File photo}) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.checkInAttendance(meetingId: meetingId, advisorId: advisorId, photo: photo);
    } catch (e) {
      debugPrint('Check-In Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> checkOut({required String meetingId, required String advisorId, required File photo}) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.checkOutAttendance(meetingId: meetingId, advisorId: advisorId, photo: photo);
    } catch (e) {
      debugPrint('Check-Out Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}