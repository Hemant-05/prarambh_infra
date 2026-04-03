// lib/features/client/presentation/providers/enquiry_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/enquiry_model.dart';
import '../../data/repositories/client_repository.dart';

class EnquiryProvider extends ChangeNotifier {
  final ClientRepository repository;

  EnquiryProvider({required this.repository});

  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  void resetState() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    notifyListeners();
  }

  Future<void> submitContactEnquiry({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String iWantTo,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    final enquiry = ContactRequest(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      iWantTo: iWantTo,
      message: message,
    );

    final result = await repository.addContactEnquiry(enquiry);
    
    if (result) {
      _isSuccess = true;
    } else {
      _error = 'Failed to submit enquiry. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitInterestedLead({
    required String clientName,
    required String clientNumber,
    required String unitId,
    required String description,
    String source = "Application",
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    final enquiry = InterestedLeadRequest(
      clientName: clientName,
      clientNumber: clientNumber,
      unitId: unitId,
      source: source,
      description: description,
    );

    final result = await repository.addInterestedLead(enquiry);
    
    if (result) {
      _isSuccess = true;
    } else {
      _error = 'Failed to submit interest. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitCareerEnquiry({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    final enquiry = CareerEnquiryRequest(
      name: name,
      email: email,
      phone: phone,
      city: city,
      description: description,
    );

    final result = await repository.addCareerEnquiry(enquiry);
    
    if (result) {
      _isSuccess = true;
    } else {
      _error = 'Failed to submit application. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
