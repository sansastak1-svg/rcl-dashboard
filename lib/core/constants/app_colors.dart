import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (RCL Branding)
  static const Color primaryBlue = Color(0xFF006AFF); // Bright blue
  static const Color royalBlue = Color(0xFF0A5FBF); // Royal blue secondary
  static const Color primaryGreen = Color(0xFF22C55E); // Green from logo
  static const Color darkGray = Color(0xFF1F2937); // Dark gray
  
  // Dark Theme Colors
  static const Color darkNavy = Color(0xFF0A1F3F); // Very dark navy
  static const Color darkNavy2 = Color(0xFF1B3A5F); // Slightly lighter navy for gradients
  
  // Secondary Colors
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color lightGreen = Color(0xFF86EFAC);
  static const Color accentGreen = Color(0xFF16A34A);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF9FAFB);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color mediumGray = Color(0xFFE5E7EB);
  static const Color gray = Color(0xFF9CA3AF);
  static const Color darkText = Color(0xFF111827);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981); // Green
  static const Color warningOrange = Color(0xFFF59E0B); // Amber
  static const Color errorRed = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Legacy status colors (kept for backward compatibility)
  static const Color success = successGreen;
  static const Color warning = warningOrange;
  static const Color error = errorRed;

  // Background
  static const Color background = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF111827);

  // Shadows & Overlays
  static const Color shadowColor = Color(0x1A000000);
  static const Color overlayColor = Color(0x80000000);
}

class AppThemeColors {
  // Light Theme
  static const lightTheme = {
    'primary': AppColors.primaryBlue,
    'secondary': AppColors.primaryGreen,
    'background': AppColors.background,
    'surface': AppColors.surfaceLight,
    'error': AppColors.error,
    'text': AppColors.darkText,
    'textSecondary': AppColors.gray,
    'divider': AppColors.mediumGray,
  };

  // Dark Theme
  static const darkTheme = {
    'primary': AppColors.lightBlue,
    'secondary': AppColors.lightGreen,
    'background': Color(0xFF0F172A),
    'surface': AppColors.surfaceDark,
    'error': Color(0xFFFCA5A5),
    'text': AppColors.white,
    'textSecondary': Color(0xFFD1D5DB),
    'divider': Color(0xFF374151),
  };
}
