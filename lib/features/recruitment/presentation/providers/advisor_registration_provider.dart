import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import 'package:prarambh_infra/features/recruitment/data/repositories/recruitment_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

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
    // Added panBackPhoto to validation
    if (leaderCodeCtrl.text.isEmpty || aadharFront == null || aadharBack == null || panPhoto == null || panBackPhoto == null || profilePhoto == null) {
      setError('Please upload all required documents and provide Leader Code.');
      return false;
    }

    setLoading(true);
    setError(null);

    try {
      // Construct reference persons JSON
      String? refPersonJson;
      if (refNameCtrl1.text.isNotEmpty || refNameCtrl2.text.isNotEmpty) {
        refPersonJson = '['
            '{"name": "${refNameCtrl1.text}", "address": "${refAddressCtrl1.text}", "contact_number": "${refPhoneCtrl1.text}"},'
            '{"name": "${refNameCtrl2.text}", "address": "${refAddressCtrl2.text}", "contact_number": "${refPhoneCtrl2.text}"}'
            ']';
      }

      final success = await repository.registerAdvisorDetailed(
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
      }

      setLoading(false);
      return success;
    } catch (e) {
      debugPrint('Registration Error: $e');
      setError(UIHelper.summarizeError(e.toString()));
      setLoading(false);
      return false;
    }
  }
}