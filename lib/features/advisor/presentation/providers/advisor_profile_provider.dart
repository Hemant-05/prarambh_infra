import 'package:flutter/material.dart';
import '../../data/models/advisor_profile_model.dart';
import '../../data/repositories/advisor_profile_repository.dart';

class AdvisorProfileProvider extends ChangeNotifier {
  final AdvisorProfileRepository repository;

  AdvisorProfileProvider({required this.repository});

  AdvisorProfileModel? _profile;
  bool _isLoading = false;

  AdvisorProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile(String advisorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await repository.getAdvisorProfile(advisorId);
    } catch (e) {
      debugPrint('Fetch Advisor Profile Error: $e');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}