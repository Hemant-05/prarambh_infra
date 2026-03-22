class AdvisorApplicationModel {
  final String id;
  final String name;
  final String status; // 'Pending', 'Docs Review', 'On Hold', 'Verified'
  final String zone;
  final String displayId;
  final String appliedDate;
  final String phone;
  final String email;
  final String location;
  final List<KycDocument> documents;

  AdvisorApplicationModel({
    required this.id,
    required this.name,
    required this.status,
    required this.zone,
    required this.displayId,
    required this.appliedDate,
    required this.phone,
    required this.email,
    required this.location,
    required this.documents,
  });

  factory AdvisorApplicationModel.fromJson(Map<String, dynamic> json) {
    return AdvisorApplicationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'Pending',
      zone: json['zone'] ?? '',
      displayId: json['display_id'] ?? '',
      appliedDate: json['applied_date'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] ?? '',
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => KycDocument.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class KycDocument {
  final String id;
  final String name;
  final String type; // 'JPG', 'PDF'
  final String size;
  final String url;

  KycDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'PDF',
      size: json['size'] ?? '',
      url: json['url'] ?? '',
    );
  }
}