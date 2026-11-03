import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFF5A623);
  static const Color primaryLight = Color(0xFFFFF3CD);
  static const Color background = Color(0xFFF8F8F8);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textGray = Color(0xFF8E8E93);
  static const Color fieldBg = Color(0xFFF2F2F7);

  static const Color statusGreenText = Color(0xFF34C759);
  static const Color statusGreenBg = Color(0xFFE8F8ED);
  static const Color statusAmberText = Color(0xFFF5A623);
  static const Color statusAmberBg = Color(0xFFFFF8E1);
  static const Color statusGrayText = Color(0xFF8E8E93);
  static const Color statusGrayBg = Color(0xFFF2F2F7);
  static const Color statusRedText = Color(0xFFFF3B30);
  static const Color statusRedBg = Color(0xFFFFEBEE);
  static const Color statusBlueText = Color(0xFF007AFF);
  static const Color statusBlueBg = Color(0xFFE3F2FD);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          hintStyle:
              const TextStyle(color: AppColors.textGray, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black12,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGray,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      );
}
