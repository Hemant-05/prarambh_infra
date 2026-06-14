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
  final String? endTime;
  final String? location;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final String? videoPath;

  AdvisorAttendanceDetail({
    required this.meetingId,
    required this.title,
    required this.meetingDate,
    required this.startTime,
    this.endTime,
    this.location,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.videoPath,
  });

  factory AdvisorAttendanceDetail.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://workiees.com/";
    
    // Parse UTC times to local string
    String? parseToLocal(String? timeStr, {bool isUtc = true}) {
      if (timeStr == null || timeStr.isEmpty || timeStr == 'null') return null;
      try {
        String fullDateTimeStr = timeStr.trim();
        if (!fullDateTimeStr.contains('-')) {
          String dStr = json['meeting_date'] ?? '';
          fullDateTimeStr = "$dStr $fullDateTimeStr";
        }
        if (isUtc) {
          if (!fullDateTimeStr.endsWith('Z')) {
            fullDateTimeStr = '${fullDateTimeStr.replaceAll(' ', 'T')}Z';
          }
          return DateTime.parse(fullDateTimeStr).toLocal().toString();
        } else {
          return DateTime.parse(fullDateTimeStr).toString();
        }
      } catch (_) {
        return timeStr;
      }
    }

    String? cInPhoto = json['check_in_photo']?.toString();
    if (cInPhoto == 'null' || (cInPhoto?.isEmpty ?? true)) cInPhoto = null;
    if (cInPhoto != null && !cInPhoto.startsWith('http')) {
      cInPhoto = baseUrl + (cInPhoto.startsWith('/') ? cInPhoto.substring(1) : cInPhoto);
    }

    String? cOutPhoto = json['check_out_photo']?.toString();
    if (cOutPhoto == 'null' || (cOutPhoto?.isEmpty ?? true)) cOutPhoto = null;
    if (cOutPhoto != null && !cOutPhoto.startsWith('http')) {
      cOutPhoto = baseUrl + (cOutPhoto.startsWith('/') ? cOutPhoto.substring(1) : cOutPhoto);
    }

    String rawVideoUrl = '';
    if (json['video_path'] != null && json['video_path'].toString().isNotEmpty) {
      rawVideoUrl = json['video_path'].toString();
    } else if (json['video_url'] != null && json['video_url'].toString().isNotEmpty) {
      rawVideoUrl = json['video_url'].toString();
    } else if (json['video'] != null && json['video'].toString().isNotEmpty) {
      rawVideoUrl = json['video'].toString();
    }
    
    String finalVideoUrl = rawVideoUrl.startsWith('http')
        ? rawVideoUrl
        : (rawVideoUrl.isNotEmpty ? baseUrl + (rawVideoUrl.startsWith('/') ? rawVideoUrl.substring(1) : rawVideoUrl) : '');

    return AdvisorAttendanceDetail(
      meetingId: json['meeting_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      meetingDate: json['meeting_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time']?.toString(),
      location: json['location']?.toString(),
      status: json['status'] ?? '',
      checkInTime: parseToLocal(json['check_in_time']?.toString(), isUtc: false),
      checkOutTime: parseToLocal(json['check_out_time']?.toString(), isUtc: false),
      checkInPhoto: cInPhoto,
      checkOutPhoto: cOutPhoto,
      videoPath: finalVideoUrl.isEmpty ? null : finalVideoUrl,
    );
  }
}
