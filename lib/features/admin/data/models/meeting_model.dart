// Meeting + Attendance models for the Meeting Management system

class MeetingModel {
  final String id;
  final String title;
  final String agenda;
  final String date;
  final String time;
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
    required this.location,
    required this.status,
    required this.createdAt,
    required this.attendanceRecords,
  });

  int get presentCount => attendanceRecords.where((r) => r.isPresent).length;
  int get absentCount => attendanceRecords.length - presentCount;

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> records = json['attendance'] ?? [];
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['meeting_title'] ?? 'Untitled Meeting',
      agenda: json['agenda'] ?? json['description'] ?? '',
      date: json['date'] ?? json['meeting_date'] ?? '',
      time: json['time'] ?? json['meeting_time'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'upcoming',
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
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      advisorId: json['advisor_id']?.toString() ?? '',
      advisorName: json['advisor_name'] ?? json['full_name'] ?? 'Unknown',
      advisorCode: json['advisor_code'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      duration: json['duration'] ?? '',
      checkInPhoto: json['check_in_photo'] ?? '',
      checkOutPhoto: json['check_out_photo'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}
