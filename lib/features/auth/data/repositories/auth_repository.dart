import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyToken = 'auth_token';

  Future<UserModel> loginAdvisor(String password, String advisorCode) async {
    try {
      final response = await apiClient.loginAdvisor({
        "password": password,
        "advisor_code": advisorCode,
      });

      if (response['status'] == 'success') {
        final userData = response['data']['user'];
        final token = response['data']['token'];

        // Save the credentials locally so auto-login works for advisors too!
        await _saveCredentials(advisorCode, password, token);
        return UserModel.fromJson(userData, token: token);
      }
      throw Exception(response['message'] ?? 'Advisor Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> loginUser(String email, String password) async {
    try {
      final response = await apiClient.loginUser({
        "email": email,
        "password": password,
      });

      if (response['status'] == 'success') {
        // Extract nested data
        final userData = response['data']['user'];
        final token = response['data']['token'];

        // Save credentials AND token securely
        await _saveCredentials(email, password, token);

        // Pass the token into the model factory
        return UserModel.fromJson(userData, token: token);
      }
      throw Exception(response['message'] ?? 'Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveCredentials(String email, String password, String token) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyPassword, value: password);
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final email = await _secureStorage.read(key: _keyEmail);
    final password = await _secureStorage.read(key: _keyPassword);
    final token = await _secureStorage.read(key: _keyToken);
    return {'email': email, 'password': password, 'token': token};
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
    await _secureStorage.delete(key: _keyToken);
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'Client', // Default role if not specified
  }) async {
    try {

      final response = await apiClient.registerUser({
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "password": password,
        "role": role,
      });

      if (response['status'] == 'success') {
        _saveCredentials(email, password, response['data']['token']);
        return true;
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await apiClient.requestPasswordReset({"email": email});
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await apiClient.verifyOtp({"email": email, "otp": otp});
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await apiClient.resetPassword({
        "email": email,
        "new_password": newPassword,
      });
      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      rethrow;
    }
  }
}