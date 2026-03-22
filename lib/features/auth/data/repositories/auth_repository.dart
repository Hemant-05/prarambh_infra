import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.loginUser({
        "email": email,
        "password": password,
      });

      if (response['status'] == 'success') {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
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