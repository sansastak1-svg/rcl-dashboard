import 'package:flutter/material.dart';
import 'package:rcl_dashboard/services/auth_service.dart';
import 'package:rcl_dashboard/features/auth/models/auth_models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  AuthToken? _token;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _biometricsAvailable = false;
  List<String> _availableBiometrics = [];

  // Getters
  User? get user => _user;
  AuthToken? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get biometricsAvailable => _biometricsAvailable;
  List<String> get availableBiometrics => _availableBiometrics;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getSavedUser();
      final token = await _authService.getSavedToken();

      if (user != null && token != null && !token.isExpired) {
        _user = user;
        _token = token;
        _isAuthenticated = true;
      }

      // Check biometrics
      _biometricsAvailable = await _authService.canUseBiometrics();
      if (_biometricsAvailable) {
        final biometrics = await _authService.getAvailableBiometrics();
        _availableBiometrics = biometrics.map((b) => b.name).toList();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (result['success']) {
        _token = result['token'];
        _user = result['user'];
        _isAuthenticated = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.forgotPassword(email: email);

      if (result['success']) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['success']) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> biometricLogin() async {
    try {
      final authenticated = await _authService.authenticateWithBiometrics(
        reason: 'Authenticate to access RCL Dashboard',
      );

      if (authenticated) {
        final user = await _authService.getSavedUser();
        final token = await _authService.getSavedToken();

        if (user != null && token != null && !token.isExpired) {
          _user = user;
          _token = token;
          _isAuthenticated = true;
          _error = null;
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> getRememberedEmail() async {
    return await _authService.getRememberedEmail();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
