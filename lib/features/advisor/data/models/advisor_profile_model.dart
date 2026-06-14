import 'dart:convert';

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
  final String leaderId;
  final String advisorType;
  final String slab;
  final String applicationNumber;
  final String maritalStatus;
  final String branchCode;
  final String branchLocation;
  final String headOffice;
  final String primaryProfession;
  final String qualification;
  final String nationality;
  final List<Map<String, String>> referencePersons;

  AdvisorProfileModel({
    required this.id,
    required this.advisorCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.designation,
    required this.status,
    required this.profilePhoto,
    required this.dob,
    required this.gender,
    required this.fatherName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.aadhaar,
    required this.pan,
    required this.occupation,
    required this.bankName,
    required this.accNumber,
    required this.ifsc,
    required this.nomineeName,
    required this.nomineePhone,
    required this.relationship,
    required this.joinedDate,
    required this.advisorType,
    required this.slab,
    required this.leaderId,
    required this.applicationNumber,
    required this.maritalStatus,
    required this.branchCode,
    required this.branchLocation,
    required this.headOffice,
    required this.primaryProfession,
    required this.qualification,
    required this.nationality,
    required this.referencePersons,
  });

  factory AdvisorProfileModel.fromJson(Map<String, dynamic> json) {
    // If the API nests the profile inside a "data" object
    final data = json.containsKey('data') ? json['data'] : json;

    const String baseUrl = "https://workiees.com/";
    String rawPath = data['profile_photo']?.toString() ?? '';
    String finalPhotoUrl = rawPath.startsWith('http')
        ? rawPath
        : (rawPath.isNotEmpty
              ? baseUrl +
                    (rawPath.startsWith('/') ? rawPath.substring(1) : rawPath)
              : '');

    List<Map<String, String>> refPersons = [];
    if (data['reference_person'] != null) {
      if (data['reference_person'] is List) {
        for (var item in (data['reference_person'] as List)) {
          if (item is Map) {
            refPersons.add({
              'name': item['name']?.toString() ?? 'N/A',
              'address': item['address']?.toString() ?? 'N/A',
              'relationship': item['relationship']?.toString() ?? 'N/A',
              'contact_number': item['contact_number']?.toString() ?? 'N/A',
            });
          }
        }
      } else if (data['reference_person'] is String) {
        try {
          var decoded = jsonDecode(data['reference_person']);
          if (decoded is List) {
            for (var item in decoded) {
              if (item is Map) {
                refPersons.add({
                  'name': item['name']?.toString() ?? 'N/A',
                  'address': item['address']?.toString() ?? 'N/A',
                  'relationship': item['relationship']?.toString() ?? 'N/A',
                  'contact_number': item['contact_number']?.toString() ?? 'N/A',
                });
              }
            }
          } else if (decoded is Map) {
            refPersons.add({
              'name': decoded['name']?.toString() ?? 'N/A',
              'address': decoded['address']?.toString() ?? 'N/A',
              'relationship': decoded['relationship']?.toString() ?? 'N/A',
              'contact_number': decoded['contact_number']?.toString() ?? 'N/A',
            });
          }
        } catch (_) {}
      } else if (data['reference_person'] is Map) {
        var decoded = data['reference_person'] as Map;
        refPersons.add({
          'name': decoded['name']?.toString() ?? 'N/A',
          'address': decoded['address']?.toString() ?? 'N/A',
          'relationship': decoded['relationship']?.toString() ?? 'N/A',
          'contact_number': decoded['contact_number']?.toString() ?? 'N/A',
        });
      }
    }

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
      slab: data['slab']?.toString() ?? '0',
      leaderId: data['leader_id']?.toString() ?? '14',
      applicationNumber: data['Application_number']?.toString() ?? data['application_number']?.toString() ?? 'N/A',
      maritalStatus: data['Marital_status']?.toString() ?? data['marital_status']?.toString() ?? 'N/A',
      branchCode: data['Branch_code']?.toString() ?? data['branch_code']?.toString() ?? 'N/A',
      branchLocation: data['Branch_location']?.toString() ?? data['branch_location']?.toString() ?? 'N/A',
      headOffice: data['Head_office']?.toString() ?? data['head_office']?.toString() ?? 'N/A',
      primaryProfession: data['Primary_profession']?.toString() ?? data['primary_profession']?.toString() ?? 'N/A',
      qualification: data['Qualification']?.toString() ?? data['qualification']?.toString() ?? 'N/A',
      nationality: data['nationality']?.toString() ?? 'Indian',
      referencePersons: refPersons,
    );
  }
}
