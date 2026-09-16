import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.lightBgPrimary,

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightTextPrimary,
        secondary: AppColors.accentOrange,
        surface: AppColors.lightBgPrimary,
        error: AppColors.lightTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgInput,
        hintStyle: const TextStyle(color: AppColors.lightTextHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightTextPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightTextPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightTextPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightTextPrimary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightTextPrimary, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.lightTextPrimary),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.lightTextPrimary,
        selectionColor: AppColors.lightBgElevated,
        selectionHandleColor: AppColors.lightTextPrimary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightTextPrimary,
          foregroundColor: AppColors.lightBgPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      dividerColor: AppColors.lightDivider,

      cardColor: AppColors.lightBgCard,

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.switchThumb),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.switchActive;
          return AppColors.lightSwitchInactive;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.lightTextPrimary;
          return AppColors.lightTextMuted;
        }),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightNavBg,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.lightNavInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightFilterBg,
        selectedColor: AppColors.filterSelectedBg,
        labelStyle: const TextStyle(color: AppColors.lightFilterText),
        secondaryLabelStyle: const TextStyle(color: AppColors.filterSelectedText),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightProgressBg,
      ),
    );
  }
}