import 'package:flutter/material.dart';

/// Centralized UI dimensions, paddings, border radiuses, and responsive breakpoints.
class AppSizes {
  AppSizes._();

  // Spacing & Padding
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Border Radius
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;
  static const double rFull = 999.0;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(rFull));

  // Responsive Breakpoints
  static const double mobileMaxWidth = 640.0;
  static const double tabletMaxWidth = 1024.0;
  static const double desktopMaxWidth = 1440.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // Card dimensions
  static const double carCardHeightMobile = 280.0;
  static const double carCardImageHeight = 160.0;
}
