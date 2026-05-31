import 'dart:convert';

class AdvisorApplicationModel {
  final String id;
  final String displayId;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String fatherName;
  final String dob;
  final String gender;
  final String nomineeName;
  final String nomineePhone;
  final String relationship;
  final String occupation;
  final String aadhaarNumber;
  final String panNumber;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String status;
  final String leaderId;
  final String appliedDate;
  final String slab;
  final String advisorType;
  final String leaderCode;
  final String applicationNumber;
  final String maritalStatus;
  final String branchCode;
  final String branchLocation;
  final String headOffice;
  final String primaryProfession;
  final String qualification;
  final String nationality;
  final String refName;
  final String refAddress;
  final String refRelationship;
  final String refContact;
  final List<KycDocument> documents;

  AdvisorApplicationModel({
    required this.id,
    required this.displayId,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.fatherName,
    required this.dob,
    required this.gender,
    required this.nomineeName,
    required this.nomineePhone,
    required this.relationship,
    required this.occupation,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.status,
    required this.leaderId,
    required this.appliedDate,
    required this.slab,
    required this.advisorType,
    required this.leaderCode,
    required this.applicationNumber,
    required this.maritalStatus,
    required this.branchCode,
    required this.branchLocation,
    required this.headOffice,
    required this.primaryProfession,
    required this.qualification,
    required this.nationality,
    required this.refName,
    required this.refAddress,
    required this.refRelationship,
    required this.refContact,
    required this.documents,
  });

  factory AdvisorApplicationModel.fromJson(Map<String, dynamic> json) {
    List<KycDocument> docs = [];
    const String imageBaseUrl = "https://workiees.com/";

    void addDocIfPresent(String key, String title) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        String rawUrl = json[key].toString();
        String fullUrl = rawUrl.startsWith('http')
            ? rawUrl
            : imageBaseUrl +
                  (rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl);

        docs.add(
          KycDocument(
            id: key,
            name: title,
            type: fullUrl.toLowerCase().endsWith('.pdf') ? 'PDF' : 'IMAGE',
            size: 'Uploaded',
            url: fullUrl,
          ),
        );
      }
    }

    addDocIfPresent('addresscard_front_photo', 'Aadhar Front');
    addDocIfPresent('addresscard_back_photo', 'Aadhar Back');
    addDocIfPresent('pancard_photo', 'PAN Card Front');
    addDocIfPresent('pancard_back_photo', 'PAN Card Back');
    addDocIfPresent('profile_photo', 'Profile Photo');

    Map<String, dynamic>? refPersonMap;
    if (json['reference_person'] is Map) {
      refPersonMap = json['reference_person'] as Map<String, dynamic>;
    } else if (json['reference_person'] is String) {
      try {
        refPersonMap =
            jsonDecode(json['reference_person']) as Map<String, dynamic>;
      } catch (e) {
        refPersonMap = null;
      }
    }

    return AdvisorApplicationModel(
      id: json['id']?.toString() ?? '',
      displayId: json['Advisor_code']?.toString() ?? '',
      name: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      designation: json['designation']?.toString() ?? 'Advisor',
      fatherName: json['father_name']?.toString() ?? '',
      dob: json['date_of_birth']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      nomineeName: json['nomineename']?.toString() ?? '',
      nomineePhone: json['nomineephone']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      occupation: json['occupation']?.toString() ?? '',
      aadhaarNumber: json['aadhaar_number']?.toString() ?? '',
      panNumber: json['pan_number']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      leaderId: json['leader_id']?.toString() ?? '',
      appliedDate: json['created_at']?.toString().split(' ')[0] ?? '',
      slab: json['slab']?.toString() ?? '',
      advisorType: json['advisor_type']?.toString() ?? 'Full-time',
      leaderCode: json['leader_code']?.toString() ?? '',
      applicationNumber: json['Application_number']?.toString() ?? 'N/A',
      maritalStatus: json['Marital_status']?.toString() ?? 'N/A',
      branchCode: json['Branch_code']?.toString() ?? 'N/A',
      branchLocation: json['Branch_location']?.toString() ?? 'N/A',
      headOffice: json['Head_office']?.toString() ?? 'N/A',
      primaryProfession: json['Primary_profession']?.toString() ?? 'N/A',
      qualification: json['Qualification']?.toString() ?? 'N/A',
      nationality: json['nationality']?.toString() ?? 'Indian',
      refName: refPersonMap?['name']?.toString() ?? 'N/A',
      refAddress: refPersonMap?['address']?.toString() ?? 'N/A',
      refRelationship: refPersonMap?['relationship']?.toString() ?? 'N/A',
      refContact: refPersonMap?['contact_number']?.toString() ?? 'N/A',
      documents: docs,
    );
  }
}

class KycDocument {
  final String id, name, type, size, url;
  KycDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
  });
}
