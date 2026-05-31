class AdvisorMeetingModel {
  final String id;
  final String title;
  final String location;
  final String meetingDate;
  final String startTime;
  final String endTime;
  final String? checkInTime;
  final String? checkOutTime;
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
    final String? cIn = (att != null ? att['check_in_time'] : json['check_in_time'])?.toString();
    final String? cOut = (att != null ? att['check_out_time'] : json['check_out_time'])?.toString();

    // Parse video URL
    const String baseUrl = "https://workiees.com/";
    String rawVideoUrl = json['video_url'] ?? json['video'] ?? '';
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
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}