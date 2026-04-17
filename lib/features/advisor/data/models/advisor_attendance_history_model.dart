class AdvisorAttendanceHistoryModel {
  final AdvisorAttendanceSummary summary;
  final List<AdvisorAttendanceDetail> meetingDetails;

  AdvisorAttendanceHistoryModel({
    required this.summary,
    required this.meetingDetails,
  });

  factory AdvisorAttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AdvisorAttendanceHistoryModel(
      summary: AdvisorAttendanceSummary.fromJson(json['summary'] ?? {}),
      meetingDetails: (json['meeting_details'] as List? ?? [])
          .map((e) => AdvisorAttendanceDetail.fromJson(e))
          .toList(),
    );
  }
}

class AdvisorAttendanceSummary {
  final double attendancePercent;
  final int totalMeetings;
  final int present;
  final int absent;

  AdvisorAttendanceSummary({
    required this.attendancePercent,
    required this.totalMeetings,
    required this.present,
    required this.absent,
  });

  factory AdvisorAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AdvisorAttendanceSummary(
      attendancePercent: (json['attendance_percent'] ?? 0).toDouble(),
      totalMeetings: json['total_meetings'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }
}

class AdvisorAttendanceDetail {
  final int meetingId;
  final String title;
  final String meetingDate;
  final String startTime;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;

  AdvisorAttendanceDetail({
    required this.meetingId,
    required this.title,
    required this.meetingDate,
    required this.startTime,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  factory AdvisorAttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AdvisorAttendanceDetail(
      meetingId: json['meeting_id'] ?? 0,
      title: json['title'] ?? '',
      meetingDate: json['meeting_date'] ?? '',
      startTime: json['start_time'] ?? '',
      status: json['status'] ?? '',
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
    );
  }
}
