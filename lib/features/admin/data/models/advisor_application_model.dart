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
  final String slab; // NEW FIELD
  final List<KycDocument> documents;

  AdvisorApplicationModel({
    required this.id, required this.displayId, required this.name, required this.email,
    required this.phone, required this.designation, required this.fatherName,
    required this.dob, required this.gender, required this.nomineeName,
    required this.nomineePhone, required this.relationship, required this.occupation,
    required this.aadhaarNumber, required this.panNumber, required this.bankName,
    required this.accountNumber, required this.ifscCode, required this.address,
    required this.city, required this.state, required this.pincode, required this.status,
    required this.leaderId, required this.appliedDate, required this.slab, required this.documents,
  });

  factory AdvisorApplicationModel.fromJson(Map<String, dynamic> json) {
    List<KycDocument> docs = [];

    // THE FIX: Removed 'api/' from the end of this URL
    const String imageBaseUrl = "https://workiees.com/";

    void addDocIfPresent(String key, String title) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        String rawUrl = json[key].toString();
        // Use imageBaseUrl instead of baseUrl
        String fullUrl = rawUrl.startsWith('http') ? rawUrl : imageBaseUrl + (rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl);

        docs.add(KycDocument(
            id: key,
            name: title,
            type: fullUrl.toLowerCase().endsWith('.pdf') ? 'PDF' : 'IMAGE',
            size: 'Uploaded',
            url: fullUrl
        ));
      }
    }

    addDocIfPresent('addresscard_front_photo', 'Aadhar Front');
    addDocIfPresent('addresscard_back_photo', 'Aadhar Back');
    addDocIfPresent('pancard_photo', 'PAN Card Front');
    addDocIfPresent('pancard_back_photo', 'PAN Card Back');
    addDocIfPresent('profile_photo', 'Profile Photo');

    return AdvisorApplicationModel(
      // ... keep all the other mappings the exactly same ...
      id: json['id']?.toString() ?? '',
      displayId: json['Advisor_code'] ?? 'PENDING-ID',
      name: json['full_name'] ?? 'Unknown',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      designation: json['designation'] ?? 'Advisor',
      fatherName: json['father_name'] ?? 'N/A',
      dob: json['date_of_birth'] ?? 'N/A',
      gender: json['gender'] ?? 'N/A',
      nomineeName: json['nomineename'] ?? 'N/A',
      nomineePhone: json['nomineephone'] ?? 'N/A',
      relationship: json['relationship'] ?? 'N/A',
      occupation: json['occupation'] ?? 'N/A',
      aadhaarNumber: json['aadhaar_number'] ?? 'N/A',
      panNumber: json['pan_number'] ?? 'N/A',
      bankName: json['bank_name'] ?? 'N/A',
      accountNumber: json['account_number'] ?? 'N/A',
      ifscCode: json['ifsc_code'] ?? 'N/A',
      address: json['address'] ?? 'N/A',
      city: json['city'] ?? 'N/A',
      state: json['state'] ?? 'N/A',
      pincode: json['pincode'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
      leaderId: json['leader_id']?.toString() ?? 'N/A',
      appliedDate: json['created_at']?.toString().split(' ')[0] ?? 'N/A',
      slab: json['slab']?.toString() ?? 'N/A',
      documents: docs,
    );
  }
}

class KycDocument {
  final String id, name, type, size, url;
  KycDocument({required this.id, required this.name, required this.type, required this.size, required this.url});
}