class TeamActivityModel {
  final TeamBookings teamBookings;
  final List<TeamAttendance> teamAttendance;

  TeamActivityModel({
    required this.teamBookings,
    required this.teamAttendance,
  });

  factory TeamActivityModel.fromJson(Map<String, dynamic> json) {
    return TeamActivityModel(
      teamBookings: TeamBookings.fromJson(json['team_bookings'] ?? {}),
      teamAttendance: (json['team_attendance'] as List? ?? [])
          .map((e) => TeamAttendance.fromJson(e))
          .toList(),
    );
  }
}

class TeamBookings {
  final List<RecentActivity> recentActivity;
  final num target;
  final num achieved;

  TeamBookings({
    required this.recentActivity,
    required this.target,
    required this.achieved,
  });

  factory TeamBookings.fromJson(Map<String, dynamic> json) {
    return TeamBookings(
      recentActivity: (json['recent_activity'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
      target: json['target'] ?? 0,
      achieved: json['achieved'] ?? 0,
    );
  }
}

class RecentActivity {
  final String advisorName;
  final String projectDetails;
  final String date;
  final String status;

  RecentActivity({
    required this.advisorName,
    required this.projectDetails,
    required this.date,
    required this.status,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      advisorName: json['advisor_name'] ?? '',
      projectDetails: json['project_details'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class TeamAttendance {
  final String advisorName;
  final String designation;
  final String? profilePhoto;
  final num attendancePercent;
  final List<String> presentDates;

  TeamAttendance({
    required this.advisorName,
    required this.designation,
    this.profilePhoto,
    required this.attendancePercent,
    required this.presentDates,
  });

  factory TeamAttendance.fromJson(Map<String, dynamic> json) {
    return TeamAttendance(
      advisorName: json['advisor_name'] ?? '',
      designation: json['designation'] ?? '',
      profilePhoto: json['profile_photo'],
      attendancePercent: json['attendance_percent'] ?? 0,
      presentDates: (json['present_dates'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
