import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/admin_attendance_repository.dart';

class AdminAttendanceProvider extends ChangeNotifier {
  final AdminAttendanceRepository repository;
  AdminAttendanceProvider({required this.repository});

  List<AttendanceModel> _records = [];
  bool _isLoading = false;

  List<AttendanceModel> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> fetchReport(String meetingId) async {
    _isLoading = true; notifyListeners();
    try {
      // _records = await repository.getAttendanceReport(meetingId);

      // Mock Data matching your UI exactly
      await Future.delayed(const Duration(milliseconds: 500));
      _records = [
        AttendanceModel(id: '1', advisorId: '101', advisorName: 'Rahul Sharma', checkInTime: '10:00 AM', checkOutTime: '11:30 AM', duration: '1h 30m', checkInStatus: 'Verified', checkOutStatus: 'Verified', checkInPhoto: 'url', checkOutPhoto: 'url', lat: '28.6219', long: '77.3628'),
        AttendanceModel(id: '2', advisorId: '102', advisorName: 'Priya Patel', checkInTime: '10:45 AM', checkOutTime: '11:30 AM', duration: '45m', checkInStatus: 'Verified', checkOutStatus: 'Pending', checkInPhoto: 'url', checkOutPhoto: '', lat: '28.6219', long: '77.3628'),
        AttendanceModel(id: '3', advisorId: '103', advisorName: 'Amit Singh', checkInTime: '11:15 AM', checkOutTime: '11:30 AM', duration: '15m', checkInStatus: 'Verified', checkOutStatus: 'Verified', checkInPhoto: 'url', checkOutPhoto: 'url', lat: '28.6219', long: '77.3628'),
      ];
    } catch (e) { debugPrint(e.toString()); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<bool> createMeeting(Map<String, dynamic> data) async {
    _isLoading = true; notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock Network delay
      // await repository.createMeeting(data);
      _isLoading = false; notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false; notifyListeners();
      return false;
    }
  }
}