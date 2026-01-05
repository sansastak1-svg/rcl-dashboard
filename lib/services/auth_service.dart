import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rcl_dashboard/features/auth/models/auth_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final LocalAuthentication _localAuth = LocalAuthentication();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Mock API delay
  Future<void> _mockDelay() async {
    await Future.delayed(Duration(milliseconds: 1500));
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      await _mockDelay();

      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Mock successful response
      final token = AuthToken(
        accessToken: 'tk_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'rf_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(Duration(days: 30)),
      );

      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
        businessName: 'RCL Rentals',
        role: 'manager',
        biometricEnabled: rememberMe,
      );

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', jsonEncode(token.toJson()));
      await prefs.setString('user', jsonEncode(user.toJson()));
      if (rememberMe) {
        await prefs.setString('remembered_email', email);
      }

      return {
        'success': true,
        'token': token,
        'user': user,
        'message': 'Login successful',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      await _mockDelay();

      if (email.isEmpty) {
        throw Exception('Email is required');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      return {
        'success': true,
        'message': 'Password reset link sent to $email',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _mockDelay();

      if (newPassword != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (newPassword.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      return {
        'success': true,
        'message': 'Password reset successful',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // Biometric Authentication
  Future<bool> canUseBiometrics() async {
    try {
      final isDeviceSupported = await _localAuth.canCheckBiometrics;
      return isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    required String reason,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Get saved user
  Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Error getting saved user: $e');
    }
    return null;
  }

  // Get saved token
  Future<AuthToken?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString('auth_token');
      if (tokenJson != null) {
        return AuthToken.fromJson(jsonDecode(tokenJson));
      }
    } catch (e) {
      debugPrint('Error getting saved token: $e');
    }
    return null;
  }

  // Get remembered email
  Future<String?> getRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('remembered_email');
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user');
      await prefs.remove('remembered_email');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getSavedToken();
      if (token == null) return false;
      return !token.isExpired;
    } catch (e) {
      return false;
    }
  }
}
