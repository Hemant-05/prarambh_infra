// lib/features/client/data/models/enquiry_model.dart

class ContactRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String iWantTo;
  final String message;

  ContactRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.iWantTo,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'i_want_to': iWantTo,
      'message': message,
    };
  }
}

class CareerEnquiryRequest {
  final String name;
  final String email;
  final String phone;
  final String city;
  final String description;

  CareerEnquiryRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'description': description,
    };
  }
}

class InterestedLeadRequest {
  final String clientName;
  final String clientNumber;
  final String unitId;
  final String source;
  final String description;

  InterestedLeadRequest({
    required this.clientName,
    required this.clientNumber,
    required this.unitId,
    this.source = "Application",
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientName,
      'client_number': clientNumber,
      'unit_id': unitId,
      'source': source,
      'description': description,
    };
  }
}
