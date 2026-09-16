import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.darkBgPrimary,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkTextPrimary,
        secondary: AppColors.accentOrange,
        surface: AppColors.darkBgSecondary,
        error: AppColors.darkTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgSecondary,
        hintStyle: const TextStyle(color: AppColors.darkTextHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTextPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTextPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTextPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTextPrimary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTextPrimary, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.darkTextPrimary),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.darkTextPrimary,
        selectionColor: AppColors.darkBgElevated,
        selectionHandleColor: AppColors.darkTextPrimary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTextPrimary,
          foregroundColor: AppColors.darkBgPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      dividerColor: AppColors.darkDivider,

      cardColor: AppColors.darkBgCard,

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.switchThumb),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.switchActive;
          return AppColors.darkSwitchInactive;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.darkTextPrimary;
          return AppColors.darkTextMuted;
        }),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkNavBg,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.darkNavInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkFilterBg,
        selectedColor: AppColors.filterSelectedBg,
        labelStyle: const TextStyle(color: AppColors.darkFilterText),
        secondaryLabelStyle: const TextStyle(color: AppColors.filterSelectedText),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkProgressBg,
      ),
    );
  }
}