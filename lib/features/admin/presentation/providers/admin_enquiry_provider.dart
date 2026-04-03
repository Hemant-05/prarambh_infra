import 'package:flutter/material.dart';
import '../../data/models/enquiry_model.dart';
import '../../data/repositories/admin_enquiry_repository.dart';

class AdminEnquiryProvider extends ChangeNotifier {
  final AdminEnquiryRepository _repository;

  AdminEnquiryProvider(this._repository);

  List<AdminEnquiryModel> _contactEnquiries = [];
  List<AdminCareerEnquiryModel> _careerEnquiries = [];
  bool _isLoading = false;
  String? _error;

  List<AdminEnquiryModel> get contactEnquiries => _contactEnquiries;
  List<AdminCareerEnquiryModel> get careerEnquiries => _careerEnquiries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchContactEnquiries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contactEnquiries = await _repository.getContactEnquiries();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCareerEnquiries({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _careerEnquiries = await _repository.getCareerEnquiries(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteContactEnquiry(String id) async {
    try {
      final success = await _repository.deleteContactEnquiry(id);
      if (success) {
        _contactEnquiries.removeWhere((e) => e.id.toString() == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCareerEnquiry(String id) async {
    try {
      final success = await _repository.deleteCareerEnquiry(id);
      if (success) {
        _careerEnquiries.removeWhere((e) => e.id.toString() == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
