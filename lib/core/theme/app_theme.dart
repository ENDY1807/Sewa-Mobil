import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'text_styles.dart';

/// Centralized ThemeData for Light and Dark themes according to Material 3.
class AppTheme {
  AppTheme._();

  // LIGHT THEME
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      error: AppColors.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      dividerColor: AppColors.borderLight,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSizes.radiusLg,
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
          shape: RoundedRectangleBorder(borderRadius: AppSizes.radiusMd),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
          shape: RoundedRectangleBorder(borderRadius: AppSizes.radiusMd),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p16),
        border: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryLight),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryContainer,
        elevation: 4,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondaryLight,
          );
        }),
      ),
    );
  }

  // DARK THEME
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      primary: AppColors.accent,
      onPrimary: Colors.black,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      error: AppColors.error,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      dividerColor: AppColors.borderDark,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSizes.radiusLg,
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
          shape: RoundedRectangleBorder(borderRadius: AppSizes.radiusMd),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
          shape: RoundedRectangleBorder(borderRadius: AppSizes.radiusMd),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p16),
        border: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSizes.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryDark),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withOpacity(0.4),
        elevation: 4,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          );
        }),
      ),
    );
  }
}
