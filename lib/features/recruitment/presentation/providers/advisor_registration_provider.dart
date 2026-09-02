import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import 'package:prarambh_infra/features/recruitment/data/repositories/recruitment_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import 'package:prarambh_infra/features/admin/data/models/review_message_model.dart';
import 'package:prarambh_infra/features/admin/data/models/team_models.dart';

class AdvisorRegistrationProvider extends ChangeNotifier with ErrorHandlerMixin {
  final RecruitmentRepository repository;
  AdvisorRegistrationProvider({required this.repository}) {
    // Auto-generate application number
    applicationNumberCtrl.text = Random().nextInt(100000).toString().padLeft(5, '0');
    // Prefill defaults
    nationalityCtrl.text = 'Indian';
    stateCtrl.text = 'Madhya Pradesh';
  }

  // errorMessage, isLoading, clearError, setError, setLoading are provided by ErrorHandlerMixin

  List<ReviewMessageModel> reviewMessages = [];
  bool isEditMode = false;
  String? editAdvisorId;

  Future<void> fetchReviewMessages(String advisorId) async {
    reviewMessages = [];
    notifyListeners();
    try {
      reviewMessages = await repository.getReviewMessages(advisorId);
      notifyListeners();
    } catch (e) {
      reviewMessages = [];
      notifyListeners();
      debugPrint('Failed to fetch review messages: $e');
    }
  }
  void preFillFromEnquiry({
    required String name,
    required String email,
    required String phone,
    required String city,
  }) {
    nameCtrl.text = name;
    emailCtrl.text = email;
    phoneCtrl.text = phone;
    cityCtrl.text = city;
    notifyListeners();
  }

  Future<void> loadApplicationData(String advisorId) async {
    isEditMode = true;
    editAdvisorId = advisorId;
    setLoading(true);
    try {
      final data = await repository.getSingleAdvisor(advisorId);
      final profile = BrokerProfileModel.fromJson(data);

      nameCtrl.text = profile.name;
      fatherNameCtrl.text = profile.fatherName;
      dobCtrl.text = profile.dateOfBirth;
      aadharCtrl.text = profile.aadhaarNumber;
      panCtrl.text = profile.panNumber;
      phoneCtrl.text = profile.phone;
      emailCtrl.text = profile.email;
      addressCtrl.text = profile.address;
      occupationCtrl.text = profile.occupation;
      pincodeCtrl.text = profile.pincode;
      
      gender = profile.gender.isNotEmpty ? profile.gender : 'Male';
      designation = profile.designation.isNotEmpty ? profile.designation : 'Advisor';
      advisorType = profile.advisorType.isNotEmpty ? profile.advisorType : 'Full time';
      stateCtrl.text = profile.state;
      cityCtrl.text = profile.city;

      if (profile.applicationNumber != 'N/A') applicationNumberCtrl.text = profile.applicationNumber;
      maritalStatus = (profile.maritalStatus.isNotEmpty && profile.maritalStatus != 'N/A') ? profile.maritalStatus : 'Single';
      if (profile.branchCode != 'N/A') branchCodeCtrl.text = profile.branchCode;
      if (profile.branchLocation != 'N/A') branchLocationCtrl.text = profile.branchLocation;
      if (profile.headOffice != 'N/A') headOfficeCtrl.text = profile.headOffice;
      if (profile.primaryProfession != 'N/A') primaryProfessionCtrl.text = profile.primaryProfession;
      qualification = (profile.qualification.isNotEmpty && profile.qualification != 'N/A') ? profile.qualification : 'Graduated';
      nationalityCtrl.text = profile.nationality;
      
      if (profile.referencePersons.isNotEmpty) {
        refNameCtrl1.text = profile.referencePersons[0]['name'] ?? '';
        refAddressCtrl1.text = profile.referencePersons[0]['address'] ?? '';
        refPhoneCtrl1.text = profile.referencePersons[0]['contact_number'] ?? '';
        
        if (profile.referencePersons.length > 1) {
          refNameCtrl2.text = profile.referencePersons[1]['name'] ?? '';
          refAddressCtrl2.text = profile.referencePersons[1]['address'] ?? '';
          refPhoneCtrl2.text = profile.referencePersons[1]['contact_number'] ?? '';
        }
      } else {
        if (profile.refName != 'N/A') refNameCtrl1.text = profile.refName;
        if (profile.refAddress != 'N/A') refAddressCtrl1.text = profile.refAddress;
        if (profile.refContact != 'N/A') refPhoneCtrl1.text = profile.refContact;
      }

      nomineeNameCtrl.text = profile.nomineeName;
      nomineeAgeCtrl.text = profile.nomineePhone;
      bankNameCtrl.text = profile.bankName;
      accNumberCtrl.text = profile.accountNumber;
      ifscCtrl.text = profile.ifscCode;
      relationship = profile.relationship.isNotEmpty ? profile.relationship : 'Wife';

      if (profile.leaderId != null && profile.leaderId!.isNotEmpty) {
        try {
          final leaderData = await repository.getSingleAdvisor(profile.leaderId!);
          final leaderProfile = BrokerProfileModel.fromJson(leaderData);
          leaderCodeCtrl.text = leaderProfile.advisorCode;
        } catch (_) {
          leaderCodeCtrl.text = profile.leaderCode ?? '';
        }
      } else {
        leaderCodeCtrl.text = profile.leaderCode ?? '';
      }

      aadharFrontUrl = profile.addressCardFrontPhoto;
      aadharBackUrl = profile.addressCardBackPhoto;
      panPhotoUrl = profile.panCardPhoto;
      panBackPhotoUrl = profile.panCardBackPhoto;
      profilePhotoUrl = profile.profilePhoto;

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load application data: $e');
      setError('Failed to load application data');
    } finally {
      setLoading(false);
    }
  }

  // --- Step 1 Controllers ---
  final nameCtrl = TextEditingController();
  final fatherNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final aadharCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  String gender = 'Male';
  String designation = 'Advisor';
  String advisorType = 'Full time';
  final stateCtrl = TextEditingController();
  final cityCtrl =  TextEditingController();

  // --- NEW FIELDS ---
  final applicationNumberCtrl = TextEditingController();
  String maritalStatus = 'Single';
  final branchCodeCtrl = TextEditingController();
  final branchLocationCtrl = TextEditingController();
  final headOfficeCtrl = TextEditingController();
  final primaryProfessionCtrl = TextEditingController();
  String qualification = 'Graduated'; // Now a dropdown
  final nationalityCtrl = TextEditingController();
  
  // Reference Person 1
  final refNameCtrl1 = TextEditingController();
  final refAddressCtrl1 = TextEditingController();
  final refPhoneCtrl1 = TextEditingController();

  // Reference Person 2
  final refNameCtrl2 = TextEditingController();
  final refAddressCtrl2 = TextEditingController();
  final refPhoneCtrl2 = TextEditingController();

  // --- Step 2 Controllers ---
  final nomineeNameCtrl = TextEditingController();
  final nomineeAgeCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final accNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  final leaderCodeCtrl = TextEditingController();

  String relationship = 'Wife';

  // --- Files ---
  File? aadharFront;
  File? aadharBack;
  File? panPhoto;
  File? panBackPhoto; // NEW FIELD
  File? profilePhoto;

  String? aadharFrontUrl;
  String? aadharBackUrl;
  String? panPhotoUrl;
  String? panBackPhotoUrl;
  String? profilePhotoUrl;

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      if (type == 'aadhar_front') aadharFront = file;
      if (type == 'aadhar_back') aadharBack = file;
      if (type == 'pan') panPhoto = file;
      if (type == 'pan_back') panBackPhoto = file; // NEW FIELD
      if (type == 'profile') profilePhoto = file;
      notifyListeners();
    }
  }

  // --- Validation & Submission ---
  bool validateStep1(BuildContext context) {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || aadharCtrl.text.isEmpty || panCtrl.text.isEmpty || dobCtrl.text.isEmpty) {
      setError('Please fill all required Personal & Contact details.');
      return false;
    }

    try {
      // dob format should be yyyy-mm-dd or dd-mm-yyyy etc. Assuming the date picker sets it to yyyy-MM-dd
      final parts = dobCtrl.text.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        int year = int.parse(parts[0].length == 4 ? parts[0] : parts[2]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[0].length == 4 ? parts[2] : parts[0]);
        final dobDate = DateTime(year, month, day);
        final age = DateTime.now().difference(dobDate).inDays / 365;
        if (age < 18) {
          setError('Advisor must be at least 18 years old.');
          return false;
        }
      }
    } catch (_) {}

    return true;
  }

  Future<bool> submitRegistration(BuildContext context) async {
    if (!isEditMode) {
      if (leaderCodeCtrl.text.isEmpty || aadharFront == null || aadharBack == null || panPhoto == null || panBackPhoto == null || profilePhoto == null) {
        setError('Please upload all required documents and provide Leader Code.');
        return false;
      }
    } else {
      if (leaderCodeCtrl.text.isEmpty) {
        setError('Please provide Leader Code.');
        return false;
      }
    }

    setLoading(true);
    setError(null);

    try {
      // Construct reference persons JSON
      String? refPersonJson;
      List<Map<String, String>> refPersons = [];
      if (refNameCtrl1.text.isNotEmpty) {
        refPersons.add({
          "name": refNameCtrl1.text,
          "address": refAddressCtrl1.text,
          "contact_number": refPhoneCtrl1.text,
        });
      }
      if (refNameCtrl2.text.isNotEmpty) {
        refPersons.add({
          "name": refNameCtrl2.text,
          "address": refAddressCtrl2.text,
          "contact_number": refPhoneCtrl2.text,
        });
      }
      if (refPersons.isNotEmpty) {
        refPersonJson = jsonEncode(refPersons);
      }

      bool success = false;
      if (isEditMode && editAdvisorId != null) {
         success = await repository.updateAdvisorDetailed(
            editAdvisorId!,
            fullName: nameCtrl.text, email: emailCtrl.text, phone: phoneCtrl.text, designation: designation,
            fatherName: fatherNameCtrl.text, dob: dobCtrl.text, gender: gender,
            nomineeName: nomineeNameCtrl.text, nomineePhone: nomineeAgeCtrl.text, relationship: relationship,
            occupation: occupationCtrl.text, aadhaar: aadharCtrl.text, pan: panCtrl.text,
            bankName: bankNameCtrl.text, accNumber: accNumberCtrl.text, ifsc: ifscCtrl.text,
            address: addressCtrl.text, city: cityCtrl.text, state: stateCtrl.text, pincode: pincodeCtrl.text, 
            leaderCode: leaderCodeCtrl.text, advisorType: advisorType,
            applicationNumber: applicationNumberCtrl.text.isEmpty ? null : applicationNumberCtrl.text,
            maritalStatus: maritalStatus,
            branchCode: branchCodeCtrl.text.isEmpty ? null : branchCodeCtrl.text,
            branchLocation: branchLocationCtrl.text.isEmpty ? null : branchLocationCtrl.text,
            headOffice: headOfficeCtrl.text.isEmpty ? null : headOfficeCtrl.text,
            primaryProfession: primaryProfessionCtrl.text.isEmpty ? null : primaryProfessionCtrl.text,
            qualification: qualification,
            nationality: nationalityCtrl.text,
            referencePerson: refPersonJson,
            aadharFront: aadharFront, aadharBack: aadharBack, panPhoto: panPhoto,
            panBackPhoto: panBackPhoto, profilePhoto: profilePhoto
         );
      } else {
         success = await repository.registerAdvisorDetailed(
            fullName: nameCtrl.text, email: emailCtrl.text, phone: phoneCtrl.text, designation: designation,
            fatherName: fatherNameCtrl.text, dob: dobCtrl.text, gender: gender,
            nomineeName: nomineeNameCtrl.text, nomineePhone: nomineeAgeCtrl.text, relationship: relationship,
            occupation: occupationCtrl.text, aadhaar: aadharCtrl.text, pan: panCtrl.text,
            bankName: bankNameCtrl.text, accNumber: accNumberCtrl.text, ifsc: ifscCtrl.text,
            address: addressCtrl.text, city: cityCtrl.text, state: stateCtrl.text, pincode: pincodeCtrl.text, leaderCode: leaderCodeCtrl.text,
            advisorType: advisorType,
            applicationNumber: applicationNumberCtrl.text.isEmpty ? null : applicationNumberCtrl.text,
            maritalStatus: maritalStatus,
            branchCode: branchCodeCtrl.text.isEmpty ? null : branchCodeCtrl.text,
            branchLocation: branchLocationCtrl.text.isEmpty ? null : branchLocationCtrl.text,
            headOffice: headOfficeCtrl.text.isEmpty ? null : headOfficeCtrl.text,
            primaryProfession: primaryProfessionCtrl.text.isEmpty ? null : primaryProfessionCtrl.text,
            qualification: qualification,
            nationality: nationalityCtrl.text.isEmpty ? null : nationalityCtrl.text,
            referencePerson: refPersonJson,
            aadharFront: aadharFront!, aadharBack: aadharBack!, panPhoto: panPhoto!,
            panBackPhoto: panBackPhoto!, 
            profilePhoto: profilePhoto!
         );
      }

      if (success) {
        nameCtrl.clear(); fatherNameCtrl.clear(); dobCtrl.clear(); aadharCtrl.clear(); panCtrl.clear();
        phoneCtrl.clear(); emailCtrl.clear(); addressCtrl.clear(); occupationCtrl.clear(); pincodeCtrl.clear();
        nomineeNameCtrl.clear(); nomineeAgeCtrl.clear(); bankNameCtrl.clear(); accNumberCtrl.clear(); ifscCtrl.clear();
        branchCtrl.clear(); leaderCodeCtrl.clear(); designation = 'Advisor';
        applicationNumberCtrl.text = Random().nextInt(100000).toString().padLeft(5, '0');
        branchCodeCtrl.clear(); branchLocationCtrl.clear();
        headOfficeCtrl.clear(); primaryProfessionCtrl.clear(); nationalityCtrl.text = 'Indian';
        refNameCtrl1.clear(); refAddressCtrl1.clear(); refPhoneCtrl1.clear();
        refNameCtrl2.clear(); refAddressCtrl2.clear(); refPhoneCtrl2.clear();
        maritalStatus = 'Single';
        qualification = 'Graduated';
        aadharFront = null; aadharBack = null; panPhoto = null; panBackPhoto = null; profilePhoto = null;
        aadharFrontUrl = null; aadharBackUrl = null; panPhotoUrl = null; panBackPhotoUrl = null; profilePhotoUrl = null;
      }

      return success;
    } catch (e) {
      debugPrint('Registration Error: $e');
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData.containsKey('message')) {
          setError(resData['message'].toString());
        } else {
          setError('Update failed: ${e.response?.statusCode} - ${e.response?.statusMessage}');
        }
      } else {
        setError('Registration failed: $e');
      }
      return false;
    } finally {
      setLoading(false);
    }
  }
}