import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================================================
  // BRAND / PRIMARY
  // ==================================================
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color accentOrange = Color(0xFFFF9800);

  // ==================================================
  // GRADIENTS
  // ==================================================
  static const Color headerGradientStart = Color(0xFFB71C1C);
  static const Color headerGradientEnd = Color(0xFFE53935);

  static const Color balanceCardStart = Color(0xFF4A6FE3);
  static const Color balanceCardMid = Color(0xFF6A4FD8);
  static const Color balanceCardEnd = Color(0xFF7B5EEA);

  static const Color profileHeaderStart = Color(0xFF00897B);
  static const Color profileHeaderEnd = Color(0xFF26A69A);

  // ==================================================
  // DARK THEME — BACKGROUNDS
  // ==================================================
  static const Color darkBgPrimary = Color(0xFF000000);
  static const Color darkBgSecondary = Color(0xFF0F0F0F);
  static const Color darkBgCard = Color(0xFF1A1A1A);
  static const Color darkBgElevated = Color(0xFF2A2A2A);

  // ==================================================
  // LIGHT THEME — BACKGROUNDS
  // ==================================================
  static const Color lightBgPrimary = Color(0xFFFFFFFF);
  static const Color lightBgSecondary = Color(0xFFF5F5F5);
  static const Color lightBgCard = Color(0xFFFFFFFF);
  static const Color lightBgInput = Color(0xFFF3F3F3);
  static const Color lightBgElevated = Color(0xFFEEEEEE);

  // ==================================================
  // DARK THEME — TEXT
  // ==================================================
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextMuted = Color(0xFF7A7A7A);
  static const Color darkTextHint = Color(0xFF5F5F5F);

  // ==================================================
  // LIGHT THEME — TEXT
  // ==================================================
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextMuted = Color(0xFF888888);
  static const Color lightTextHint = Color(0xFFAAAAAA);

  // ==================================================
  // DARK THEME — BORDERS & DIVIDERS
  // ==================================================
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF1F1F1F);
  static const Color darkCardBorder = Color(0x332A2A2A);

  // ==================================================
  // LIGHT THEME — BORDERS & DIVIDERS
  // ==================================================
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFE5E5E5);
  static const Color lightCardBorder = Color(0xFFEEEEEE);

  // ==================================================
  // STATUS — SHARED
  // ==================================================
  static const Color success = Color(0xFF2ECC71);
  static const Color successBg = Color(0x332ECC71);
  static const Color error = Color(0xFFE53935);
  static const Color errorBg = Color(0x33E53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningBg = Color(0x33FF9800);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoBg = Color(0x3342A5F5);

  // ==================================================
  // TRANSACTIONS — SHARED
  // ==================================================
  static const Color incomeAmount = Color(0xFF2ECC71);
  static const Color incomeIconBg = Color(0x332ECC71);
  static const Color expenseAmount = Color(0xFFE53935);
  static const Color expenseIconBg = Color(0x33E53935);
  static const Color transferColor = Color(0xFFB39DDB);
  static const Color transferIconBg = Color(0x33B39DDB);
  static const Color goalAmount = Color(0xFF42A5F5);
  static const Color goalIconBg = Color(0x3342A5F5);
  static const Color dateLabel = Color(0xFF8A8A8A);

  // ==================================================
  // SAVINGS / GOALS — SHARED
  // ==================================================
  static const Color savingsPrimary = Color(0xFF42A5F5);
  static const Color savingsSecondary = Color(0xFF64B5F6);
  static const Color savingsIconBg = Color(0x3342A5F5);
  static const Color savingsCardBg = Color(0xFF141A22);
  static const Color savingsBorder = Color(0x33296FFF);
  static const Color goalActiveColor = Color(0xFF42A5F5);
  static const Color goalCompletedColor = Color(0xFF2ECC71);
  static const Color goalTagBg = Color(0xFF1E3A5F);
  static const Color goalTagText = Color(0xFF64B5F6);
  static const Color dailySavingBg = Color(0xFFFFF3E0);
  static const Color dailySavingText = Color(0xFFE65100);

  // ==================================================
  // ACCOUNTS — SHARED
  // ==================================================
  static const Color accountsCardBg = Color(0xFF1A2035);
  static const Color cashDotColor = Color(0xFF2ECC71);
  static const Color bankDotColor = Color(0xFF42A5F5);
  static const Color reservedColor = Color(0xFFFF9800);

  // ==================================================
  // CHARTS — SHARED
  // ==================================================
  static const Color chartIncome = Color(0xFF20C997);
  static const Color chartExpense = Color(0xFFE53935);
  static const Color chartBarBlue = Color(0xFF4285F4);
  static const Color darkChartGrid = Color(0xFF2A2A2A);
  static const Color lightChartGrid = Color(0xFFEEEEEE);

  // ==================================================
  // PROGRESS — SHARED
  // ==================================================
  static const Color progressRed = Color(0xFFE53935);
  static const Color progressGreen = Color(0xFF2ECC71);
  static const Color darkProgressBg = Color(0xFF2A2A2A);
  static const Color lightProgressBg = Color(0xFFEEEEEE);

  // ==================================================
  // SEARCH & FILTERS
  // ==================================================
  static const Color darkSearchBg = Color(0xFF1A1A1A);
  static const Color lightSearchBg = Color(0xFFF3F3F3);
  static const Color searchIcon = Color(0xFF8A8A8A);
  static const Color darkFilterBg = Color(0xFF2A2A2A);
  static const Color lightFilterBg = Color(0xFFF0F0F0);
  static const Color filterSelectedBg = Color(0xFFE53935);
  static const Color filterSelectedText = Color(0xFFFFFFFF);
  static const Color darkFilterText = Color(0xFFB0B0B0);
  static const Color lightFilterText = Color(0xFF555555);

  // ==================================================
  // BOTTOM NAV
  // ==================================================
  static const Color darkNavBg = Color(0xFF0F0F0F);
  static const Color lightNavBg = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFFE53935);
  static const Color darkNavInactive = Color(0xFF8A8A8A);
  static const Color lightNavInactive = Color(0xFF9E9E9E);

  // ==================================================
  // PROFILE & SETTINGS
  // ==================================================
  static const Color switchActive = Color(0xFFE53935);
  static const Color darkSwitchInactive = Color(0xFF4A4A4A);
  static const Color lightSwitchInactive = Color(0xFFCCCCCC);
  static const Color switchThumb = Color(0xFFFFFFFF);
  static const Color upgradeButtonBg = Color(0xFFFF9800);
  static const Color listTileArrow = Color(0xFF8A8A8A);

  // ==================================================
  // CATEGORY ICON COLORS
  // ==================================================
  static const Color catSalary = Color(0xFF2ECC71);
  static const Color catInvest = Color(0xFF42A5F5);
  static const Color catRental = Color(0xFF7986CB);
  static const Color catFreelance = Color(0xFF2ECC71);
  static const Color catBusiness = Color(0xFFFF9800);
  static const Color catGrants = Color(0xFFFF9800);
  static const Color catFood = Color(0xFFFF7043);
  static const Color catTransport = Color(0xFFE53935);
  static const Color catShopping = Color(0xFFAB47BC);
  static const Color catHealth = Color(0xFF26C6DA);
  static const Color catEntertainment = Color(0xFFFFCA28);
  static const Color catEmergency = Color(0xFFE53935);
  static const Color catBills = Color(0xFF78909C);
  static const Color catTravel = Color(0xFF42A5F5);
  static const Color catOther = Color(0xFF90A4AE);
}