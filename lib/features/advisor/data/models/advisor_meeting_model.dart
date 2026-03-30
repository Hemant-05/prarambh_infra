class AdvisorMeetingModel {
  final String id;
  final String title;
  final String location;
  final String meetingDate;
  final String startTime;
  final String endTime;

  AdvisorMeetingModel({
    required this.id,
    required this.title,
    required this.location,
    required this.meetingDate,
    required this.startTime,
    required this.endTime,
  });

  factory AdvisorMeetingModel.fromJson(Map<String, dynamic> json) {
    return AdvisorMeetingModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Meeting',
      location: json['location'] ?? 'HQ',
      meetingDate: json['meeting_date'] ?? '',
      startTime: json['start_time'] ?? '--:--',
      endTime: json['end_time'] ?? '--:--',
    );
  }
}