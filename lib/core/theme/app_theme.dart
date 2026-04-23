import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          surface: AppColors.background,
          primary: AppColors.textPrimary,
          onPrimary: Colors.white,
          secondary: AppColors.textSecondary,
          onSecondary: Colors.white,
          outline: AppColors.border,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w600, letterSpacing: -1.5, color: AppColors.textPrimary),
          displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, letterSpacing: -0.8, color: AppColors.textPrimary),
          headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, color: AppColors.textPrimary, height: 1.15),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: AppColors.textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: AppColors.textPrimary),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.1, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.1, color: AppColors.textPrimary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
          labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.textPrimary, width: 1),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border, width: 1)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border, width: 1)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textPrimary, width: 1)),
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          labelStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.textPrimary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: -0.1),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: -0.1),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
      );
}
