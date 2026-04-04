class RecruitmentDashboardModel {
  final int totalRecruits;
  final int activeRecruits;
  final int pendingApprovals;
  final int inactiveOrSuspended;
  final List<RecruitedPersonModel> recentApplications;

  RecruitmentDashboardModel({
    required this.totalRecruits, required this.activeRecruits,
    required this.pendingApprovals, required this.inactiveOrSuspended,
    required this.recentApplications,
  });

  factory RecruitmentDashboardModel.fromJson(Map<String, dynamic> json) {
    int parseStat(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    int total = parseStat(json['metrics']?['total_recruits']);
    int active = parseStat(json['metrics']?['active_recruits']);
    
    // Subtract 1 from total and active to exclude Admin
    return RecruitmentDashboardModel(
      totalRecruits: total > 0 ? total - 1 : 0,
      activeRecruits: active > 0 ? active - 1 : 0,
      pendingApprovals: parseStat(json['metrics']?['pending_approvals']),
      inactiveOrSuspended: parseStat(json['metrics']?['inactive_or_suspended']),
      recentApplications: (json['recent_applications'] as List<dynamic>?)
              ?.map((e) => RecruitedPersonModel.fromJson(e))
              .where((m) =>
                  m.advisorCode.toLowerCase() != 'admin001' &&
                  m.designation.toLowerCase() != 'admin')
              .toList() ??
          [],
    );
  }
}

class RecruiterModel {
  final String id;
  final String name;
  final String joinedDate;
  final int recruitCount;
  final String initials;

  RecruiterModel({
    required this.id, required this.name, required this.joinedDate,
    required this.recruitCount, required this.initials,
  });

  factory RecruiterModel.fromJson(Map<String, dynamic> json) => RecruiterModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    joinedDate: json['joined_date'] ?? '',
    recruitCount: json['recruit_count'] ?? 0,
    initials: json['initials'] ?? '',
  );
}

class RecruitedPersonModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String advisorCode;
  final String joinedDate;
  final String status;
  final String initials;

  RecruitedPersonModel({
    required this.id, required this.name, required this.email,
    required this.phone, required this.designation,
    required this.advisorCode, required this.joinedDate,
    required this.status, required this.initials,
  });

  factory RecruitedPersonModel.fromJson(Map<String, dynamic> json) {
    String n = json['name'] ?? json['full_name'] ?? 'Unknown User';
    String computedInitials = json['initials'] ?? '';
    if (computedInitials.isEmpty && n.trim().isNotEmpty) {
      computedInitials = n.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    }
    return RecruitedPersonModel(
      id: json['id']?.toString() ?? '',
      name: n,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      designation: json['designation'] ?? 'Advisor',
      advisorCode: json['Advisor_code'] ?? '',
      joinedDate: json['joined_date'] ?? json['created_at']?.toString().split(' ')[0] ?? '',
      status: json['status'] ?? 'Pending',
      initials: computedInitials,
    );
  }
}