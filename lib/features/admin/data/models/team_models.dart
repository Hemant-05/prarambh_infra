class AdvisorNode {
  final String id;
  final String name;
  final String role;
  final String code;
  final String avatarUrl;
  final List<AdvisorNode> children;

  AdvisorNode({
    required this.id, required this.name, required this.role,
    required this.code, required this.avatarUrl, this.children = const [],
  });

  factory AdvisorNode.fromJson(Map<String, dynamic> json) {
    var childrenList = json['children'] ?? json['team_members'];
    return AdvisorNode(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      role: json['role'] ?? json['designation'] ?? '',
      code: json['code'] ?? json['Advisor_code'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['profile_photo'] ?? '',
      children: (childrenList as List<dynamic>?)?.map((e) => AdvisorNode.fromJson(e)).toList() ?? [],
    );
  }
}

// ── Full Advisor Detail Profile ──────────────────────────────────────────────

class TeamMemberModel {
  final String id;
  final String advisorCode;
  final String fullName;
  final String designation;
  final String? profilePhoto;

  TeamMemberModel({
    required this.id, required this.advisorCode,
    required this.fullName, required this.designation,
    this.profilePhoto,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) => TeamMemberModel(
    id: json['id']?.toString() ?? '',
    advisorCode: json['Advisor_code'] ?? '',
    fullName: json['full_name'] ?? '',
    designation: json['designation'] ?? '',
    profilePhoto: json['profile_photo'],
  );

  String get initials {
    String trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';
    List<String> parts = trimmed.split(' ').where((s) => s.trim().isNotEmpty).toList();
    if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}

class DocumentFileModel {
  final String name;
  final String category;
  final String filePath;
  DocumentFileModel({required this.name, required this.category, required this.filePath});
  factory DocumentFileModel.fromJson(Map<String, dynamic> json) => DocumentFileModel(
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    filePath: json['file_path'] ?? '',
  );
}

class ContestModel {
  final String title;
  final String rewardName;
  final String? rewardImage;
  final String endDate;
  final String selling;
  final int units;
  ContestModel({required this.title, required this.rewardName, this.rewardImage, required this.endDate, required this.selling, required this.units});
  factory ContestModel.fromJson(Map<String, dynamic> json) => ContestModel(
    title: json['title'] ?? '',
    rewardName: json['reward_name'] ?? '',
    rewardImage: json['reward_image'],
    endDate: json['end_date'] ?? '',
    selling: json['selling']?.toString() ?? '0',
    units: json['units'] ?? 0,
  );
}

class AttendanceEntryModel {
  final String date;
  final String status;
  AttendanceEntryModel({required this.date, required this.status});
  factory AttendanceEntryModel.fromJson(Map<String, dynamic> json) => AttendanceEntryModel(
    date: json['date'] ?? '',
    status: json['status'] ?? 'Absent',
  );
}

class BrokerProfileModel {
  // Advisor Details 
  final String id;
  final String advisorCode;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String fatherName;
  final String dateOfBirth;
  final String gender;
  final String nomineeName;
  final String nomineePhone;
  final String relationship;
  final String occupation;
  final String? addressCardFrontPhoto;
  final String? addressCardBackPhoto;
  final String? panCardPhoto;
  final String? panCardBackPhoto;
  final String? profilePhoto;
  final String aadhaarNumber;
  final String panNumber;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String slab;
  final String status;
  final String? leaderId;
  final String createdAt;

  // My Team
  final List<TeamMemberModel> myTeam;

  // Sales Pipeline
  final Map<String, int> salesPipeline;

  // Business Performance  
  final double personalSales;
  final double teamSales;

  // Attendance
  final List<AttendanceEntryModel> attendanceTracker;
  final int teamAttendanceTotal;
  final int teamAttendancePresent;
  final int teamAttendanceAbsent;

  // Documents
  final String? docAddressCardFront;
  final String? docAddressCardBack;
  final String? docPanCard;
  final String? docPanCardBack;
  final String? docProfile;
  final List<DocumentFileModel> otherFiles;

  // Achievements & Contests
  final List<dynamic> achievements;
  final List<ContestModel> contests;
  final List<dynamic> upcomingInstallments;

  BrokerProfileModel({
    required this.id, required this.advisorCode, required this.name,
    required this.email, required this.phone, required this.designation,
    required this.fatherName, required this.dateOfBirth, required this.gender,
    required this.nomineeName, required this.nomineePhone, required this.relationship,
    required this.occupation,
    this.addressCardFrontPhoto, this.addressCardBackPhoto, this.panCardPhoto,
    this.panCardBackPhoto, this.profilePhoto,
    required this.aadhaarNumber, required this.panNumber, required this.bankName,
    required this.accountNumber, required this.ifscCode, required this.address,
    required this.city, required this.state, required this.pincode,
    required this.slab, required this.status, this.leaderId, required this.createdAt,
    required this.myTeam, required this.salesPipeline,
    required this.personalSales, required this.teamSales,
    required this.attendanceTracker, required this.teamAttendanceTotal,
    required this.teamAttendancePresent, required this.teamAttendanceAbsent,
    this.docAddressCardFront, this.docAddressCardBack, this.docPanCard,
    this.docPanCardBack, this.docProfile, required this.otherFiles,
    required this.achievements, required this.contests, required this.upcomingInstallments,
  });

  factory BrokerProfileModel.fromJson(Map<String, dynamic> json) {
    final ad = json['advisor_details'] as Map<String, dynamic>? ?? json;
    final docs = json['documents'] as Map<String, dynamic>? ?? {};
    final myTeamRaw = json['my_team'] as List<dynamic>? ?? [];
    final pipelineRaw = json['sales_pipeline'] as Map<String, dynamic>? ?? {};
    final perfRaw = json['business_performance'] as Map<String, dynamic>? ?? {};
    final attendanceRaw = json['attendance_tracker'] as List<dynamic>? ?? [];
    final todayTeam = json['today_team_attendance'] as Map<String, dynamic>? ?? {};
    final otherFilesRaw = (docs['other_files'] as List<dynamic>?) ?? [];
    final contestsRaw = json['contests'] as List<dynamic>? ?? [];

    return BrokerProfileModel(
      id: ad['id']?.toString() ?? '',
      advisorCode: ad['Advisor_code'] ?? '',
      name: ad['full_name'] ?? '',
      email: ad['email'] ?? '',
      phone: ad['phone'] ?? '',
      designation: ad['designation'] ?? '',
      fatherName: ad['father_name'] ?? '',
      dateOfBirth: ad['date_of_birth'] ?? '',
      gender: ad['gender'] ?? '',
      nomineeName: ad['nomineename'] ?? '',
      nomineePhone: ad['nomineephone'] ?? '',
      relationship: ad['relationship'] ?? '',
      occupation: ad['occupation'] ?? '',
      addressCardFrontPhoto: ad['addresscard_front_photo'],
      addressCardBackPhoto: ad['addresscard_back_photo'],
      panCardPhoto: ad['pancard_photo'],
      panCardBackPhoto: ad['pancard_back_photo'],
      profilePhoto: ad['profile_photo'],
      aadhaarNumber: ad['aadhaar_number'] ?? '',
      panNumber: ad['pan_number'] ?? '',
      bankName: ad['bank_name'] ?? '',
      accountNumber: ad['account_number'] ?? '',
      ifscCode: ad['ifsc_code'] ?? '',
      address: ad['address'] ?? '',
      city: ad['city'] ?? '',
      state: ad['state'] ?? '',
      pincode: ad['pincode'] ?? '',
      slab: ad['slab']?.toString() ?? '0',
      status: ad['status'] ?? 'Pending',
      leaderId: ad['leader_id']?.toString(),
      createdAt: ad['created_at'] ?? '',
      myTeam: myTeamRaw.map((e) => TeamMemberModel.fromJson(e)).toList(),
      salesPipeline: pipelineRaw.map((k, v) => MapEntry(k, v is int ? v : (v as num).toInt())),
      personalSales: (perfRaw['personal_sales'] is num) ? (perfRaw['personal_sales'] as num).toDouble() : 0.0,
      teamSales: (perfRaw['team_sales'] is num) ? (perfRaw['team_sales'] as num).toDouble() : 0.0,
      attendanceTracker: attendanceRaw.map((e) => AttendanceEntryModel.fromJson(e)).toList(),
      teamAttendanceTotal: todayTeam['total'] ?? 0,
      teamAttendancePresent: todayTeam['present'] ?? 0,
      teamAttendanceAbsent: todayTeam['absent'] ?? 0,
      docAddressCardFront: docs['addresscard_front'],
      docAddressCardBack: docs['addresscard_back'],
      docPanCard: docs['pancard'],
      docPanCardBack: docs['pancard_back'],
      docProfile: docs['profile'],
      otherFiles: otherFilesRaw.map((e) => DocumentFileModel.fromJson(e)).toList(),
      achievements: json['achievements'] as List<dynamic>? ?? [],
      contests: contestsRaw.map((e) => ContestModel.fromJson(e)).toList(),
      upcomingInstallments: json['upcoming_installments'] as List<dynamic>? ?? [],
    );
  }

  String get initials {
    String trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    List<String> parts = trimmed.split(' ').where((s) => s.trim().isNotEmpty).toList();
    if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}