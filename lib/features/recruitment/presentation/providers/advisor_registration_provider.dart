import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';
import 'package:prarambh_infra/features/recruitment/data/repositories/recruitment_repository.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';

class AdvisorRegistrationProvider extends ChangeNotifier with ErrorHandlerMixin {
  final RecruitmentRepository repository;
  AdvisorRegistrationProvider({required this.repository});

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
    // Also added dobCtrl verification since it's required by the backend
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || aadharCtrl.text.isEmpty || panCtrl.text.isEmpty || dobCtrl.text.isEmpty) {
      setError('Please fill all required Personal & Contact details.');
      return false;
    }
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
      final success = await repository.registerAdvisorDetailed(
          fullName: nameCtrl.text, email: emailCtrl.text, phone: phoneCtrl.text, designation: designation,
          fatherName: fatherNameCtrl.text, dob: dobCtrl.text, gender: gender,
          nomineeName: nomineeNameCtrl.text, nomineePhone: nomineePhoneCtrl.text, relationship: relationship,
          occupation: occupationCtrl.text, aadhaar: aadharCtrl.text, pan: panCtrl.text,
          bankName: bankNameCtrl.text, accNumber: accNumberCtrl.text, ifsc: ifscCtrl.text,
          address: addressCtrl.text, city: cityCtrl.text, state: stateCtrl.text, pincode: pincodeCtrl.text, leaderCode: leaderCodeCtrl.text,
          advisorType: advisorType,
          aadharFront: aadharFront!, aadharBack: aadharBack!, panPhoto: panPhoto!,
          panBackPhoto: panBackPhoto!, 
          profilePhoto: profilePhoto!
      );

      if(success){
        nameCtrl.clear(); fatherNameCtrl.clear(); dobCtrl.clear(); aadharCtrl.clear(); panCtrl.clear();
        phoneCtrl.clear(); emailCtrl.clear(); addressCtrl.clear(); occupationCtrl.clear(); pincodeCtrl.clear();
        nomineeNameCtrl.clear(); nomineePhoneCtrl.clear(); bankNameCtrl.clear(); accNumberCtrl.clear(); ifscCtrl.clear();
        branchCtrl.clear(); leaderCodeCtrl.clear(); designation = 'Advisor';
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