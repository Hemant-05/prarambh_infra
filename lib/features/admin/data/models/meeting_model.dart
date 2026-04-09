// Meeting + Attendance models for the Meeting Management system

class MeetingModel {
  final String id;
  final String title;
  final String agenda;
  final String date;
  final String time;
  final String endTime;
  final String location;
  final String status; // upcoming | ongoing | completed
  final String createdAt;
  final List<AttendanceRecord> attendanceRecords;

  MeetingModel({
    required this.id,
    required this.title,
    required this.agenda,
    required this.date,
    required this.time,
    required this.endTime,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.attendanceRecords,
  });

  int get presentCount => attendanceRecords.where((r) => r.isPresent).length;
  int get absentCount => attendanceRecords.length - presentCount;

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    // Handle both capital 'A' and small 'a' for attendance
    final List<dynamic> records = json['attendance'] ?? json['Attendance'] ?? [];
    final String dateStr = json['meeting_date'] ?? json['date'] ?? '';
    final String startTimeStr = json['time'] ?? json['meeting_time'] ?? json['start_time'] ?? '';
    final String endTimeStr = json['end_time'] ?? '';
    
    String calculatedStatus = json['status']?.toString().toLowerCase() ?? 'upcoming';

    // Robust status calculation if not explicitly marked completed by server
    if (calculatedStatus != 'completed' && dateStr.isNotEmpty) {
      try {
        final now = DateTime.now();
        
        DateTime? startDT;
        DateTime? endDT;

        // Helper to parse date + time
        DateTime? parseDT(String t) {
          if (t.isEmpty || t == '--:--') return null;
          // Attempt simple parse. DateTime.parse expects YYYY-MM-DD HH:mm:ss
          try {
            return DateTime.parse("${dateStr.trim()} ${t.trim()}");
          } catch (_) {
            return null;
          }
        }

        startDT = parseDT(startTimeStr);
        endDT = parseDT(endTimeStr);

        if (endDT != null && now.isAfter(endDT)) {
          calculatedStatus = 'completed';
        } else if (startDT != null && now.isAfter(startDT)) {
          if (endDT == null || now.isBefore(endDT)) {
            calculatedStatus = 'ongoing';
          }
        } else {
          // Check date only as fallback
          final mDate = DateTime.parse(dateStr);
          final today = DateTime(now.year, now.month, now.day);
          final meetingDateOnly = DateTime(mDate.year, mDate.month, mDate.day);

          if (meetingDateOnly.isBefore(today)) {
            calculatedStatus = 'completed';
          } else if (meetingDateOnly.isAtSameMomentAs(today)) {
            // Already handled by time checks above, but if times are null:
            if (startDT == null) calculatedStatus = 'ongoing';
          }
        }
      } catch (e) {
        // Fallback or keep server status
      }
    }

    return MeetingModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['meeting_title'] ?? 'Untitled Meeting',
      agenda: json['agenda'] ?? json['description'] ?? '',
      date: dateStr,
      time: startTimeStr,
      endTime: endTimeStr,
      location: json['location'] ?? '',
      status: calculatedStatus,
      createdAt: json['created_at'] ?? '',
      attendanceRecords: records.map((e) => AttendanceRecord.fromJson(e)).toList(),
    );
  }
}

class AttendanceRecord {
  final String id;
  final String advisorId;
  final String advisorName;
  final String advisorCode;
  final String checkInTime;
  final String checkOutTime;
  final String duration;
  final String checkInPhoto;
  final String checkOutPhoto;
  final String status; // present | absent | pending

  AttendanceRecord({
    required this.id,
    required this.advisorId,
    required this.advisorName,
    required this.advisorCode,
    required this.checkInTime,
    required this.checkOutTime,
    required this.duration,
    required this.checkInPhoto,
    required this.checkOutPhoto,
    required this.status,
  });

  bool get isPresent => status.toLowerCase() == 'present' || checkInTime.isNotEmpty;
  bool get hasCheckedOut => checkOutTime.isNotEmpty && checkOutTime != '--:--';

  String get initials {
    final parts = advisorName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Helper to extract ONLY time from a possible date-time string
    String extractTime(dynamic val) {
      if (val == null || val == 'null') return '';
      final str = val.toString();
      if (str.contains(' ')) {
        return str.split(' ').last;
      }
      return str;
    }

    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      advisorId: json['advisor_id']?.toString() ?? '',
      advisorName: json['full_name'] ?? json['advisor_name'] ?? 'Unknown',
      advisorCode: json['Advisor_code'] ?? json['advisor_code'] ?? '',
      checkInTime: extractTime(json['check_in_time']),
      checkOutTime: extractTime(json['check_out_time']),
      duration: json['duration'] ?? '',
      checkInPhoto: json['check_in_photo'] ?? '',
      checkOutPhoto: json['check_out_photo'] ?? '',
      status: json['status'] ?? (json['check_in_time'] != null ? 'present' : 'pending'),
    );
  }
}
