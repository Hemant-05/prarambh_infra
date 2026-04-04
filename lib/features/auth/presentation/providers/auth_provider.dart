import 'package:flutter/material.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

import 'package:prarambh_infra/core/providers/error_handler_mixin.dart';

enum ForgotPasswordStep { email, otp, reset }

class AuthProvider extends ChangeNotifier with ErrorHandlerMixin {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      _currentUser = await authRepository.loginUser(email, password);
      setLoading(false);
      return true; // Login success
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('401') || errorMsg.contains('unauthorized')) {
        setError('Incorrect ID or password. Please try again.');
      } else {
        setError(UIHelper.summarizeError(errorMsg));
      }
      setLoading(false);
      return false; // Login failed
    }
  }

  Future<bool> loginAdvisor(
      String password, String advisorCode) async {
    setLoading(true);
    setError(null);

    try {
      _currentUser = await authRepository.loginAdvisor(password, advisorCode);
      setLoading(false);
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('401') || errorMsg.contains('unauthorized')) {
        setError('Incorrect ID or password. Please try again.');
      } else {
        setError(UIHelper.summarizeError(errorMsg));
      }
      setLoading(false);
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final creds = await authRepository.getSavedCredentials();
    final identifier = creds['identifier']; // Email or Advisor Code
    final password = creds['password'];
    final role = creds['role'];

    // If nothing is saved, fail silently and let the app show the Login screen
    if (identifier == null || password == null || role == null) {
      return false;
    }

    try {
      // Route the background login based on the saved role
      if (role == 'Advisor' || role == "Admin") {
        _currentUser = await authRepository.loginAdvisor(password, identifier);
      } else {
        _currentUser = await authRepository.loginUser(identifier, password);
      }

      notifyListeners();
      return true; // Success! Splash screen can now route to Dashboard.

    } catch (e) {
      // If silent login fails (password changed, account deleted, etc.), wipe storage
      await authRepository.clearCredentials();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.clearCredentials();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    setLoading(true);
    setError(null);
    notifyListeners();

    try {
      // 1. Perform registration
      await authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      // 2. Perform auto-login to set _currentUser and save credentials
      _currentUser = await authRepository.loginUser(email, password);

      setLoading(false);
      return true; // Success
    } catch (e) {
      setError(UIHelper.summarizeError(e.toString()));
      setLoading(false);
      return false; // Failed
    }
  }


  ForgotPasswordStep _forgotPasswordStep = ForgotPasswordStep.email;
  String _resetEmail = ''; // Store the email temporarily during the flow

  ForgotPasswordStep get forgotPasswordStep => _forgotPasswordStep;

  // Resets the state when the user opens the screen
  void clearForgotPasswordState() {
    _forgotPasswordStep = ForgotPasswordStep.email;
    _resetEmail = '';
    setError(null);
    notifyListeners();
  }

  Future<bool> requestOtp(String email) async {
    setLoading(true);
    try {
      await authRepository.requestPasswordReset(email);
      _resetEmail = email;
      _forgotPasswordStep = ForgotPasswordStep.otp; // Move to next step
      setError(null);
      setLoading(false);
      return true;
    } catch (e) {
      setError(UIHelper.summarizeError(e.toString()));
      setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    setLoading(true);
    try {
      await authRepository.verifyOtp(_resetEmail, otp);
      _forgotPasswordStep = ForgotPasswordStep.reset; // Move to final step
      setError(null);
      setLoading(false);
      return true;
    } catch (e) {
      setError(UIHelper.summarizeError(e.toString()));
      setLoading(false);
      return false;
    }
  }

  Future<bool> setNewPassword(String newPassword,String otp) async {
    setLoading(true);
    try {
      await authRepository.resetPassword(_resetEmail, newPassword, otp);
      setError(null);
      setLoading(false);
      return true; // Success, ready to navigate back to login
    } catch (e) {
      setError(UIHelper.summarizeError(e.toString()));
      setLoading(false);
      return false;
    }
  }
}