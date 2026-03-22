class AttendanceModel {
  final String id;
  final String advisorId;
  final String advisorName;
  final String checkInTime;
  final String checkOutTime;
  final String duration;
  final String checkInStatus; // 'Verified', 'Pending', 'Late'
  final String checkOutStatus; // 'Verified', 'Pending'
  final String checkInPhoto;
  final String checkOutPhoto;
  final String lat;
  final String long;

  AttendanceModel({
    required this.id, required this.advisorId, required this.advisorName,
    required this.checkInTime, required this.checkOutTime, required this.duration,
    required this.checkInStatus, required this.checkOutStatus,
    required this.checkInPhoto, required this.checkOutPhoto,
    required this.lat, required this.long,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '', advisorId: json['advisor_id']?.toString() ?? '',
      advisorName: json['advisor_name'] ?? '', checkInTime: json['check_in_time'] ?? '--:--',
      checkOutTime: json['check_out_time'] ?? '--:--', duration: json['duration'] ?? '--',
      checkInStatus: json['check_in_status'] ?? 'Pending', checkOutStatus: json['check_out_status'] ?? 'Pending',
      checkInPhoto: json['check_in_photo'] ?? '', checkOutPhoto: json['check_out_photo'] ?? '',
      lat: json['lat'] ?? '', long: json['long'] ?? '',
    );
  }
}