class AdvisorProfileModel {
  final String id;
  final String advisorCode;
  final String fullName;
  final String email;
  final String phone;
  final String designation;
  final String status;
  final String profilePhoto;
  final String dob;
  final String gender;
  final String fatherName;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String aadhaar;
  final String pan;
  final String occupation;
  final String bankName;
  final String accNumber;
  final String ifsc;
  final String nomineeName;
  final String nomineePhone;
  final String relationship;
  final String joinedDate;
  final String advisorType;

  AdvisorProfileModel({
    required this.id, required this.advisorCode, required this.fullName,
    required this.email, required this.phone, required this.designation,
    required this.status, required this.profilePhoto, required this.dob,
    required this.gender, required this.fatherName, required this.address,
    required this.city, required this.state, required this.pincode,
    required this.aadhaar, required this.pan, required this.occupation,
    required this.bankName, required this.accNumber, required this.ifsc,
    required this.nomineeName, required this.nomineePhone, required this.relationship,
    required this.joinedDate, required this.advisorType,
  });

  factory AdvisorProfileModel.fromJson(Map<String, dynamic> json) {
    // If the API nests the profile inside a "data" object
    final data = json.containsKey('data') ? json['data'] : json;

    const String baseUrl = "https://workiees.com/";
    String rawPath = data['profile_photo']?.toString() ?? '';
    String finalPhotoUrl = rawPath.startsWith('http')
        ? rawPath
        : (rawPath.isNotEmpty ? baseUrl + (rawPath.startsWith('/') ? rawPath.substring(1) : rawPath) : '');

    return AdvisorProfileModel(
      id: data['id']?.toString() ?? '',
      advisorCode: data['Advisor_code'] ?? data['advisor_code'] ?? 'N/A',
      fullName: data['full_name'] ?? data['name'] ?? 'Unknown',
      email: data['email'] ?? 'N/A',
      phone: data['phone'] ?? 'N/A',
      designation: data['designation'] ?? 'Advisor',
      status: data['status'] ?? 'Active',
      profilePhoto: finalPhotoUrl,
      dob: data['date_of_birth'] ?? data['dob'] ?? 'N/A',
      gender: data['gender'] ?? 'N/A',
      fatherName: data['father_name'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
      city: data['city'] ?? 'N/A',
      state: data['state'] ?? 'N/A',
      pincode: data['pincode'] ?? 'N/A',
      aadhaar: data['aadhaar_number'] ?? data['aadhaar'] ?? 'N/A',
      pan: data['pan_number'] ?? data['pan'] ?? 'N/A',
      occupation: data['occupation'] ?? 'N/A',
      bankName: data['bank_name'] ?? 'N/A',
      accNumber: data['account_number'] ?? 'N/A',
      ifsc: data['ifsc_code'] ?? data['ifsc'] ?? 'N/A',
      nomineeName: data['nomineename'] ?? data['nominee_name'] ?? 'N/A',
      nomineePhone: data['nomineephone'] ?? data['nominee_phone'] ?? 'N/A',
      relationship: data['relationship'] ?? 'N/A',
      joinedDate: data['created_at']?.toString().split(' ')[0] ?? 'N/A',
      advisorType: data['advisor_type']?.toString() ?? 'Full-time',
    );
  }
}