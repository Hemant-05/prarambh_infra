class AdvisorMeetingModel {
  final String id;
  final String title;
  final String location;
  final String meetingDate;
  final String startTime;
  final String endTime;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final String status; // upcoming | ongoing | completed
  final String videoUrl;

  AdvisorMeetingModel({
    required this.id,
    required this.title,
    required this.location,
    required this.meetingDate,
    required this.startTime,
    required this.endTime,
    this.checkInTime,
    this.checkOutTime,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.status = 'upcoming',
    this.videoUrl = '',
  });

  factory AdvisorMeetingModel.fromJson(Map<String, dynamic> json) {
    final String dateStr = json['meeting_date'] ?? '';
    final String sTime = json['start_time'] ?? '--:--';
    final String eTime = json['end_time'] ?? '--:--';
    String serverStatus = json['status']?.toString().toLowerCase() ?? 'upcoming';

    // Robust time-based status calculation
    String calculatedStatus = serverStatus;
    if (serverStatus != 'completed' && dateStr.isNotEmpty) {
      try {
        final now = DateTime.now();
        
        DateTime? parseDT(String t) {
          if (t.isEmpty || t == '--:--') return null;
          try {
            return DateTime.parse("${dateStr.trim()} ${t.trim()}");
          } catch (_) {
            return null;
          }
        }

        final startDT = parseDT(sTime);
        final endDT = parseDT(eTime);

        if (endDT != null && now.isAfter(endDT)) {
          calculatedStatus = 'completed';
        } else if (startDT != null && now.isAfter(startDT)) {
          calculatedStatus = 'ongoing';
        }
      } catch (_) {}
    }

    final att = json['my_attendance'];
    
    String? parseToLocal(String? timeStr, {bool isUtc = true}) {
      if (timeStr == null || timeStr.isEmpty || timeStr == 'null') return null;
      try {
        String fullDateTimeStr = timeStr.trim();
        if (!fullDateTimeStr.contains('-')) {
          fullDateTimeStr = "$dateStr $fullDateTimeStr";
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

    String? cIn = parseToLocal((att != null ? att['check_in_time'] : json['check_in_time'])?.toString(), isUtc: false);
    String? cOut = parseToLocal((att != null ? att['check_out_time'] : json['check_out_time'])?.toString(), isUtc: false);

    const String baseUrl = "https://workiees.com/";
    String? cInPhoto = (att != null ? att['check_in_photo'] : json['check_in_photo'])?.toString();
    if (cInPhoto == 'null' || (cInPhoto?.isEmpty ?? true)) cInPhoto = null;
    if (cInPhoto != null && !cInPhoto.startsWith('http')) {
      cInPhoto = baseUrl + (cInPhoto.startsWith('/') ? cInPhoto.substring(1) : cInPhoto);
    }

    String? cOutPhoto = (att != null ? att['check_out_photo'] : json['check_out_photo'])?.toString();
    if (cOutPhoto == 'null' || (cOutPhoto?.isEmpty ?? true)) cOutPhoto = null;
    if (cOutPhoto != null && !cOutPhoto.startsWith('http')) {
      cOutPhoto = baseUrl + (cOutPhoto.startsWith('/') ? cOutPhoto.substring(1) : cOutPhoto);
    }

    // Parse video URL
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

    return AdvisorMeetingModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Meeting',
      location: json['location'] ?? 'HQ',
      meetingDate: dateStr,
      startTime: sTime,
      endTime: eTime,
      checkInTime: cIn,
      checkOutTime: cOut,
      checkInPhoto: cInPhoto,
      checkOutPhoto: cOutPhoto,
      status: calculatedStatus,
      videoUrl: finalVideoUrl,
    );
  }

  AdvisorMeetingModel copyWith({
    String? id,
    String? title,
    String? location,
    String? meetingDate,
    String? startTime,
    String? endTime,
    String? checkInTime,
    String? checkOutTime,
    String? checkInPhoto,
    String? checkOutPhoto,
    String? status,
    String? videoUrl,
  }) {
    return AdvisorMeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      meetingDate: meetingDate ?? this.meetingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInPhoto: checkInPhoto ?? this.checkInPhoto,
      checkOutPhoto: checkOutPhoto ?? this.checkOutPhoto,
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}