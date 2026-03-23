import 'package:flutter/material.dart';
import '../../data/models/admin_profile_model.dart';
import '../../data/repositories/admin_profile_repository.dart';

class AdminProfileProvider extends ChangeNotifier {
  final AdminProfileRepository repository;

  AdminProfileProvider({required this.repository});

  AdminProfileModel? _profile;
  bool _isLoading = false;

  AdminProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true; notifyListeners();
    try {
      // _profile = await repository.getProfile();

      // Mock Data for UI testing
      await Future.delayed(const Duration(milliseconds: 400));
      _profile = AdminProfileModel(
          id: '1', name: 'Amit Jadhav', email: 'admin@prarambhinfra.com',
          phone: '+91 9876543210', role: 'Super Admin', avatarUrl: ''
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}