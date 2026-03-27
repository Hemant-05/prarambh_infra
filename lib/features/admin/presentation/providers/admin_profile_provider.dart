import 'package:flutter/material.dart';
import '../../data/models/admin_profile_model.dart';
import '../../data/repositories/admin_profile_repository.dart';

class AdminProfileProvider extends ChangeNotifier {
  final AdminProfileRepository repository;

  AdminProfileProvider({required this.repository});

  AdminProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;

  AdminProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> fetchProfile(String userId) async {
    _isLoading = true; notifyListeners();
    try {
      _profile = await repository.getProfile(userId);
    } catch (e) {
      debugPrint('Fetch Profile Error: $e');
      // Mock data for UI testing
      _profile = AdminProfileModel(
        id: userId,
        name: 'Amit Jadhav',
        email: 'admin@prarambhinfra.com',
        phone: '+91 9876543210',
        role: 'Super Admin',
        avatarUrl: '',
      );
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    _isSaving = true; notifyListeners();
    try {
      final success = await repository.updateProfile(userId, data);
      if (success) await fetchProfile(userId);
      return success;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isSaving = true; notifyListeners();
    try {
      return await repository.deleteUser(userId);
    } catch (e) {
      debugPrint('Delete User Error: $e');
      return false;
    } finally {
      _isSaving = false; notifyListeners();
    }
  }
}