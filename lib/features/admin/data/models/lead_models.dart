class LeadModel {
  final String id;
  final String source; // e.g., 'WEBSITE INQUIRY'
  final String timeAgo;
  final String name;
  final String email;
  final String phone;
  final String projectName;
  final String projectImage;
  final String? assignedAdvisor; // Null if new
  // Extended details for assignment screen
  final String priority;
  final String notes;
  final List<String> tags;

  LeadModel({
    required this.id, required this.source, required this.timeAgo,
    required this.name, required this.email, required this.phone,
    required this.projectName, required this.projectImage,
    this.assignedAdvisor, this.priority = 'Standard', this.notes = '',
    this.tags = const [],
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
    id: json['id']?.toString() ?? '', source: json['source'] ?? '', timeAgo: json['time_ago'] ?? '',
    name: json['name'] ?? '', email: json['email'] ?? '', phone: json['phone'] ?? '',
    projectName: json['project_name'] ?? '', projectImage: json['project_image'] ?? '',
    assignedAdvisor: json['assigned_advisor'], priority: json['priority'] ?? 'Standard',
    notes: json['notes'] ?? '', tags: List<String>.from(json['tags'] ?? []),
  );
}

class AdvisorAssignModel {
  final String id;
  final String name;
  final bool isOnline;
  final int activeLeads;
  final String conversionRate;
  final bool isWarning; // To show orange conv rate

  AdvisorAssignModel({
    required this.id, required this.name, required this.isOnline,
    required this.activeLeads, required this.conversionRate, required this.isWarning,
  });

  factory AdvisorAssignModel.fromJson(Map<String, dynamic> json) => AdvisorAssignModel(
    id: json['id']?.toString() ?? '', name: json['name'] ?? '', isOnline: json['is_online'] ?? false,
    activeLeads: json['active_leads'] ?? 0, conversionRate: json['conversion_rate'] ?? '0%',
    isWarning: json['is_warning'] ?? false,
  );
}

class PipelineLeadModel {
  final String id;
  final String name;
  final String project;
  final String advisorName;
  final String lastActiveDate;
  final String stage; // 'Suspecting', 'Prospecting', 'Site Visit', etc.

  PipelineLeadModel({
    required this.id, required this.name, required this.project,
    required this.advisorName, required this.lastActiveDate, required this.stage,
  });

  factory PipelineLeadModel.fromJson(Map<String, dynamic> json) => PipelineLeadModel(
    id: json['id']?.toString() ?? '', name: json['name'] ?? '',
    project: json['project'] ?? '', advisorName: json['advisor_name'] ?? '',
    lastActiveDate: json['last_active'] ?? '', stage: json['stage'] ?? 'Suspecting',
  );
}

class LeadActivityModel {
  final String title;
  final String description;
  final String timestamp;
  final String type; // 'Call', 'Email', 'System'
  final String status; // 'CONNECTED', 'SENT', ''

  LeadActivityModel({
    required this.title, required this.description, required this.timestamp,
    required this.type, required this.status,
  });
}