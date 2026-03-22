import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum ForgotPasswordStep { email, otp, reset }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Login Logic
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await authRepository.login(email, password);
      _errorMessage = null;
      _setLoading(false);
      return true; // Success
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false; // Failed
    }
  }

  // Register Logic
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      _errorMessage = null;
      _setLoading(false);
      return true; // Success
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false; // Failed
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  ForgotPasswordStep _forgotPasswordStep = ForgotPasswordStep.email;
  String _resetEmail = ''; // Store the email temporarily during the flow

  ForgotPasswordStep get forgotPasswordStep => _forgotPasswordStep;

  // Resets the state when the user opens the screen
  void clearForgotPasswordState() {
    _forgotPasswordStep = ForgotPasswordStep.email;
    _resetEmail = '';
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> requestOtp(String email) async {
    _setLoading(true);
    try {
      await authRepository.requestPasswordReset(email);
      _resetEmail = email;
      _forgotPasswordStep = ForgotPasswordStep.otp; // Move to next step
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _setLoading(true);
    try {
      await authRepository.verifyOtp(_resetEmail, otp);
      _forgotPasswordStep = ForgotPasswordStep.reset; // Move to final step
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> setNewPassword(String newPassword) async {
    _setLoading(true);
    try {
      await authRepository.resetPassword(_resetEmail, newPassword);
      _errorMessage = null;
      _setLoading(false);
      return true; // Success, ready to navigate back to login
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }
}