import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/features/recruitment/data/repositories/recruitment_repository.dart';

class AdvisorRegistrationProvider extends ChangeNotifier {
  final RecruitmentRepository repository;
  AdvisorRegistrationProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
  final pincodeCtrl = TextEditingController(); // Missing in UI, needed for API

  String gender = 'Male';
  String state = 'Madhya Pradesh';
  String city = 'Hoshangabad';

  // --- Step 2 Controllers ---
  final nomineeNameCtrl = TextEditingController();
  final nomineePhoneCtrl = TextEditingController();
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
  File? profilePhoto; // Missing in UI, needed for API

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      if (type == 'aadhar_front') aadharFront = file;
      if (type == 'aadhar_back') aadharBack = file;
      if (type == 'pan') panPhoto = file;
      if (type == 'profile') profilePhoto = file;
      notifyListeners();
    }
  }

  // --- Validation & Submission ---
  bool validateStep1(BuildContext context) {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || aadharCtrl.text.isEmpty || panCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required Personal & Contact details.')));
      return false;
    }
    return true;
  }

  Future<bool> submitRegistration(BuildContext context) async {
    if (leaderCodeCtrl.text.isEmpty || aadharFront == null || aadharBack == null || panPhoto == null || profilePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload all required documents and provide Leader Code.')));
      return false;
    }

    _isLoading = true; notifyListeners();
    try {
      final success = await repository.registerAdvisorDetailed(
          fullName: nameCtrl.text, email: emailCtrl.text, phone: phoneCtrl.text, designation: 'Advisor',
          fatherName: fatherNameCtrl.text, dob: dobCtrl.text, gender: gender,
          nomineeName: nomineeNameCtrl.text, nomineePhone: nomineePhoneCtrl.text, relationship: relationship,
          occupation: occupationCtrl.text, aadhaar: aadharCtrl.text, pan: panCtrl.text,
          bankName: bankNameCtrl.text, accNumber: accNumberCtrl.text, ifsc: ifscCtrl.text,
          address: addressCtrl.text, city: city, state: state, pincode: pincodeCtrl.text, leaderCode: leaderCodeCtrl.text,
          aadharFront: aadharFront!, aadharBack: aadharBack!, panPhoto: panPhoto!, profilePhoto: profilePhoto!
      );

      _isLoading = false; notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false; notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      return false;
    }
  }
}