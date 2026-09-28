import 'package:flutter/material.dart';

/// Centralized application color palette.
/// Follows Material 3 styling with Deep Blue / Indigo primary branding.
class AppColors {
  AppColors._();

  // Primary - Deep Blue / Indigo
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy/Indigo
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color primaryLighter = Color(0xFF3B82F6); // Soft Blue
  static const Color primaryContainer = Color(0xFFDBEAFE); // Indigo 100
  static const Color onPrimary = Colors.white;

  // Secondary & Accents
  static const Color accent = Color(0xFF0EA5E9); // Sky Blue
  static const Color secondary = Color(0xFF0284C7);
  static const Color secondaryContainer = Color(0xFFE0F2FE);

  // Neutral - Light Theme
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white card
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Neutral - Dark Theme
  static const Color backgroundDark = Color(0xFF0A0F1D); // Deep Obsidian
  static const Color surfaceDark = Color(0xFF131D33); // Dark Navy Surface
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Car Availability Status Colors
  static const Color available = Color(0xFF10B981);
  static const Color rented = Color(0xFF6366F1);
  static const Color reserved = Color(0xFFF59E0B);
  static const Color maintenance = Color(0xFF64748B);
  static const Color unavailable = Color(0xFFEF4444);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
