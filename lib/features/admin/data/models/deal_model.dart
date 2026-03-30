class DealModel {
  final int id;
  final String clientName;
  final String clientNumber;
  final String clientEmail;
  final String clientAdharFront;
  final int propertyId;
  final bool isResale;
  final String notes;
  final String dealStatus;
  final String paymentMode;
  final String paymentStatus;
  final String createdAt;
  final List<dynamic> propertyDocs; // NEW
  final List<dynamic> installments; // NEW

  DealModel({
    required this.id, required this.clientName, required this.clientNumber,
    required this.clientEmail, required this.clientAdharFront, required this.propertyId,
    required this.isResale, required this.notes, required this.dealStatus,
    required this.paymentMode, required this.paymentStatus, required this.createdAt,
    required this.propertyDocs, required this.installments,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://workiees.com/";

    // Safely parse the documents array and append base URL to files
    List<dynamic> docs = json['property_docs'] is List ? json['property_docs'] : [];
    List<dynamic> parsedDocs = docs.map((doc) {
      String url = doc['url'] ?? '';
      if (url.isNotEmpty && !url.startsWith('http')) {
        url = baseUrl + (url.startsWith('/') ? url.substring(1) : url);
      }
      return {'title': doc['title'], 'url': url};
    }).toList();

    return DealModel(
      id: json['id'] ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientNumber: json['client_number']?.toString() ?? '',
      clientEmail: json['client_email']?.toString() ?? '',
      clientAdharFront: json['client_adhar_front']?.toString() ?? '',
      propertyId: json['property_id'] != null ? int.tryParse(json['property_id'].toString()) ?? 0 : 0,
      isResale: json['is_resale'] == 1 || json['is_resale'] == '1',
      notes: json['notes']?.toString() ?? '',
      dealStatus: json['deal_status']?.toString() ?? 'not verified',
      paymentMode: json['payment_mode']?.toString() ?? 'online',
      paymentStatus: json['payment_status']?.toString() ?? 'Pending',
      createdAt: json['created_at']?.toString().split(' ')[0] ?? '',
      propertyDocs: parsedDocs,
      installments: json['installments'] is List ? json['installments'] : [],
    );
  }
}