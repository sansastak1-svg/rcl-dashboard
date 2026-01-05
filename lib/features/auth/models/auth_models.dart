class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String businessName;
  final String? businessLogo;
  final String? phone;
  final String role;
  final bool biometricEnabled;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.businessName,
    this.businessLogo,
    this.phone,
    required this.role,
    this.biometricEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      businessName: json['businessName'] as String? ?? 'RCL Rentals',
      businessLogo: json['businessLogo'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'manager',
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'businessName': businessName,
      'businessLogo': businessLogo,
      'phone': phone,
      'role': role,
      'biometricEnabled': biometricEnabled,
    };
  }
}

class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isExpiringSoon =>
      DateTime.now().add(Duration(minutes: 5)).isAfter(expiresAt);

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expiresIn'] as int? ?? 3600;
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}
