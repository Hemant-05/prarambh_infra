import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyIdentifier = 'auth_identifier';
  static const String _keyPassword = 'auth_password';
  static const String _keyRole = 'auth_role';

  // --- 1. USER LOGIN ---
  Future<UserModel> loginUser(String email, String password) async {
    try {
      final response = await apiClient.loginUser({
        "email": email,
        "password": password,
      });

      // THE FIX: Check for both boolean true and string 'success'
      final status = response['status'];
      if (status == true || status == 'success') {
        final userData = response['data']['user'] ?? response['data'];
        userData['role'] = 'User';
        // Save identifier as Email, and Role as User
        await _saveCredentials(email, password, 'User');
        return UserModel.fromJson(userData);
      }
      throw Exception(response['message'] ?? 'Login failed');
    } catch (e) {
      rethrow;
    }
  }

  // --- 2. ADVISOR LOGIN ---
  Future<UserModel> loginAdvisor(String password, String advisorCode) async {
    try {
      final response = await apiClient.loginAdvisor({
        "password": password,
        "Advisor_code": advisorCode, // Matches your Postman payload
      });

      // THE FIX: Check for both boolean true and string 'success'
      final status = response['status'];
      if (status == true || status == 'success') {
        final userData = response['data']['user'] ?? response['data'];

        String role = advisorCode.contains('admin') ? 'Admin' : 'Advisor';
        userData['role'] = role;
        // Save identifier as Advisor Code, and Role as Advisor
        await _saveCredentials(advisorCode, password, role);
        return UserModel.fromJson(userData);
      }
      throw Exception(response['message'] ?? 'Advisor Login failed');
    } catch (e) {
      rethrow;
    }
  }

  // --- SECURE STORAGE HELPERS ---
  Future<void> _saveCredentials(
    String identifier,
    String password,
    String role,
  ) async {
    await _secureStorage.write(key: _keyIdentifier, value: identifier);
    await _secureStorage.write(key: _keyPassword, value: password);
    await _secureStorage.write(key: _keyRole, value: role);
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    return {
      'identifier': await _secureStorage.read(key: _keyIdentifier),
      'password': await _secureStorage.read(key: _keyPassword),
      'role': await _secureStorage.read(key: _keyRole),
    };
  }

  Future<void> clearCredentials() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'User', // Default role if not specified
  }) async {
    try {
      final response = await apiClient.registerUser({
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "password": password,
      });

      final status = response['status'];
      if (status == true || status == 'success') {
        _saveCredentials(email, password, 'User');
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
      final status = response['status'];
      if (status == true || status == 'success') {
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
      final status = response['status'];
      if (status == true || status == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(
    String email,
    String newPassword,
    String otp,
  ) async {
    try {
      final response = await apiClient.resetPassword({
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      });
      final status = response['status'];
      if (status == true || status == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      rethrow;
    }
  }
}
