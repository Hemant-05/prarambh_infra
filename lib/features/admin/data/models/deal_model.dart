import 'dart:convert';

class DealModel {
  final int id;
  final String clientName;
  final String clientNumber;
  final String advisorCode;
  final String clientEmail;
  final String clientAdharFront;
  final String clientAdharBack;
  final String clientPanFront;
  final String clientPanBack;
  final int propertyId;
  final int unitId;
  final String stage;
  final int leadId;
  final bool isResale;
  final List<dynamic> notes;
  final String dealStatus;
  final String? tokenAmount;
  final String? tokenPaymentMode;
  final String? tokenDate;
  final dynamic paymentPlan;
  final String? paymentAmount;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> propertyDocs;
  final List<dynamic> installments;

  DealModel({
    required this.id, required this.clientName, required this.clientNumber,
    required this.advisorCode,
    required this.unitId,
    required this.clientEmail, required this.clientAdharFront, required this.clientAdharBack,
    required this.clientPanFront, required this.clientPanBack, required this.propertyId,
    required this.stage, required this.leadId,
    required this.isResale, required this.notes, required this.dealStatus,
    this.tokenAmount, this.tokenPaymentMode, this.tokenDate,
    required this.propertyDocs, this.paymentPlan, required this.installments,
    this.paymentAmount, required this.paymentStatus, required this.createdAt,
    required this.updatedAt,
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

    List<dynamic> parseJsonList(dynamic value) {
      if (value is List) return value;
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded;
        } catch (_) {}
      }
      return [];
    }

    return DealModel(
      id: json['id'] ?? 0,
      clientName: json['client_name']?.toString() ?? '',
      clientNumber: json['client_number']?.toString() ?? '',
      advisorCode: json['advisor_code']?.toString() ?? '',
      clientEmail: json['client_email']?.toString() ?? '',
      clientAdharFront: json['client_adhar_front']?.toString() ?? '',
      clientAdharBack: json['client_adhar_back']?.toString() ?? '',
      clientPanFront: json['client_pan_front']?.toString() ?? '',
      clientPanBack: json['client_pan_back']?.toString() ?? '',
      propertyId: json['property_id'] != null ? int.tryParse(json['property_id'].toString()) ?? 0 : 0,
      unitId: json['unit_id'] != null ? int.tryParse(json['unit_id'].toString()) ?? 0 : 0,
      stage: json['stage']?.toString() ?? '',
      leadId: json['lead_id'] != null ? int.tryParse(json['lead_id'].toString()) ?? 0 : 0,
      isResale: json['is_resale'] == 1 || json['is_resale'] == '1',
      notes: parseJsonList(json['notes']),
      dealStatus: json['deal_status']?.toString() ?? 'not verified',
      tokenAmount: json['token_amount']?.toString(),
      tokenPaymentMode: json['token_payment_mode']?.toString(),
      tokenDate: json['token_date']?.toString(),
      propertyDocs: parsedDocs,
      paymentPlan: json['payment_plan'],
      installments: parseJsonList(json['installments']),
      paymentAmount: json['payment_amount']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? 'Pending',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
