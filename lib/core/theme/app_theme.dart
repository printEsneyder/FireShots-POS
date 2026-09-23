import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppConstants.primaryGold,
      secondary: AppConstants.primaryOrange,
      surface: AppConstants.backgroundCard,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppConstants.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.backgroundCard,
        foregroundColor: AppConstants.textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.backgroundCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.textGray.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.textGray.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryGold, width: 2),
        ),
        labelStyle: const TextStyle(color: AppConstants.textGray),
        hintStyle: const TextStyle(color: AppConstants.textGray),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
              headlineLarge: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.textWhite,
              ),
              headlineMedium: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppConstants.textWhite,
              ),
              bodyLarge: const TextStyle(
                fontSize: 16,
                color: AppConstants.textWhite,
              ),
              bodyMedium: const TextStyle(
                fontSize: 14,
                color: AppConstants.textGray,
              ),
            ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.backgroundCard,
        selectedItemColor: AppConstants.primaryGold,
        unselectedItemColor: AppConstants.textGray,
      ),
    );
  }
}
