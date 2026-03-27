import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/admin_attendance_repository.dart';

class AdminAttendanceProvider extends ChangeNotifier {
  final AdminAttendanceRepository repository;
  AdminAttendanceProvider({required this.repository});

  List<AttendanceModel> _records = [];
  bool _isLoading = false;
  bool _isSaving = false;
  dynamic _currentMeeting;

  List<AttendanceModel> get records => _records;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  dynamic get currentMeeting => _currentMeeting;

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

  /// Fetch attendance report. NOTE: New ApiClient has no dedicated
  /// getAttendance endpoint — attendance is embedded in meeting records.
  Future<void> fetchReport(String meetingId) async {
    _isLoading = true; notifyListeners();
    try {
      _records = await repository.getAttendanceReport();

      // Fallback mock data if no backend endpoint yet
      if (_records.isEmpty) {
        _records = [
          AttendanceModel(id: '1', advisorId: '101', advisorName: 'Rahul Sharma', checkInTime: '10:00 AM', checkOutTime: '11:30 AM', duration: '1h 30m', checkInStatus: 'Verified', checkOutStatus: 'Verified', checkInPhoto: 'url', checkOutPhoto: 'url', lat: '28.6219', long: '77.3628'),
          AttendanceModel(id: '2', advisorId: '102', advisorName: 'Priya Patel', checkInTime: '10:45 AM', checkOutTime: '11:30 AM', duration: '45m', checkInStatus: 'Verified', checkOutStatus: 'Pending', checkInPhoto: 'url', checkOutPhoto: '', lat: '28.6219', long: '77.3628'),
          AttendanceModel(id: '3', advisorId: '103', advisorName: 'Amit Singh', checkInTime: '11:15 AM', checkOutTime: '11:30 AM', duration: '15m', checkInStatus: 'Verified', checkOutStatus: 'Verified', checkInPhoto: 'url', checkOutPhoto: 'url', lat: '28.6219', long: '77.3628'),
        ];
      }
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> addMeeting(Map<String, dynamic> data) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.addMeeting(data);
    } catch (e) {
      debugPrint('Add Meeting Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> checkIn({
    required String meetingId,
    required String advisorId,
    required File photo,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.checkInAttendance(
        meetingId: meetingId,
        advisorId: advisorId,
        photo: photo,
      );
    } catch (e) {
      debugPrint('Check-In Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> checkOut({
    required String meetingId,
    required String advisorId,
    required File photo,
  }) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.checkOutAttendance(
        meetingId: meetingId,
        advisorId: advisorId,
        photo: photo,
      );
    } catch (e) {
      debugPrint('Check-Out Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}