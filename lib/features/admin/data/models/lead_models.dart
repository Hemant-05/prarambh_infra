class LeadModel {
  final String id;
  final String clientName;
  final String clientNumber;
  final String advisorCode;
  final String source;
  final String clientAge;
  final String clientOccupation;
  final String leadCategory;   // A, B, C
  final String leadPotential;  // Hot, Warm, Cold
  final String clientAddress;
  final String ownsHouse;
  final String annualIncome;
  final bool keyDecisionMaker; // 1 or 0 -> Yes/No
  final bool isPriority;
  final String siteVisitPhoto;
  final String stage;
  final int propertyId;
  final String callOutCome;
  final String reason;
  final String notes;
  final String reminder;
  final String meetingPoint;
  final int communicationAttempt;
  final String createdAt;
  final String updatedAt;

  LeadModel({
    required this.id, required this.clientName, required this.clientNumber,
    required this.advisorCode, required this.source, required this.clientAge,
    required this.clientOccupation, required this.leadCategory, required this.leadPotential,
    required this.clientAddress, required this.ownsHouse, required this.annualIncome,
    required this.keyDecisionMaker, required this.isPriority, required this.siteVisitPhoto,
    required this.stage, required this.propertyId, required this.callOutCome,
    required this.reason, required this.notes, required this.reminder,
    required this.meetingPoint, required this.communicationAttempt,
    required this.createdAt, required this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    // FIX: Parse out the default zero-time from the database
    String parsedReminder = json['reminder']?.toString() ?? '';
    if (parsedReminder == '0000-00-00 00:00:00') parsedReminder = '';

    return LeadModel(
      id: json['id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? 'Unknown Client',
      clientNumber: json['client_number']?.toString() ?? 'N/A',
      advisorCode: json['advisor_code']?.toString() ?? '',
      source: json['source']?.toString() ?? 'Generated',

      clientAge: json['client_age']?.toString() ?? 'N/A',
      clientOccupation: json['client_occupation']?.toString() ?? 'N/A',

      // Separate Category and Potential
      leadCategory: json['lead_category']?.toString() ?? 'A',
      leadPotential: json['lead_potential']?.toString() ?? 'Warm',

      clientAddress: json['client_address']?.toString() ?? 'N/A',
      ownsHouse: json['owns_house']?.toString() ?? 'N/A',
      annualIncome: json['annual_income']?.toString() ?? 'N/A',

      // FIX: Decision maker is now boolean (1 = Yes, 0 = No)
      keyDecisionMaker: json['key_decision_maker'] == 1 || json['key_decision_maker'] == '1' || json['key_decision_maker'] == true,

      isPriority: json['is_priority'] == 1 || json['is_priority'] == true,
      siteVisitPhoto: (() {
        String rawPhoto = json['site_visit_photo']?.toString() ?? '';
        if (rawPhoto.isEmpty) return '';
        if (rawPhoto.startsWith('http')) return rawPhoto;
        return "https://workiees.com/${rawPhoto.startsWith('/') ? rawPhoto.substring(1) : rawPhoto}";
      })(),

      stage: (json['stage'] == null || json['stage'].toString().isEmpty) ? 'suspecting' : json['stage'].toString(),

      propertyId: json['property_id'] != null ? int.tryParse(json['property_id'].toString()) ?? 0 : 0,
      callOutCome: json['call_outcome']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      reminder: parsedReminder, // Uses the cleaned string
      meetingPoint: json['meeting_point']?.toString() ?? '',

      communicationAttempt: json['communication_attempt'] != null ? int.tryParse(json['communication_attempt'].toString()) ?? 0 : 0,
      createdAt: json['created_at']?.toString().split(' ')[0] ?? '',
      updatedAt: json['updated_at']?.toString().split(' ')[0] ?? '',
    );
  }
}

class AdvisorAssignModel {
  final String advisorCode;
  final String name;
  final String profile;
  final int activeLeads;

  AdvisorAssignModel({
    required this.name,
    required this.activeLeads, required this.advisorCode, required this.profile,
  });

  factory AdvisorAssignModel.fromJson(Map<String, dynamic> json) => AdvisorAssignModel(
    name: json['name'] ?? '',
    activeLeads: json['active_leads'] ?? 0,
    advisorCode: json['advisor_code'] ?? '', profile: json['profile'] ?? '',
  );
}