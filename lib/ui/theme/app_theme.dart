import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF20428C);
  static const secondary = Color(0xFF78C143);
  static const tertiaryBrand = Color(0xFF47A147);
  static const tint = Color(0xFF55A11F);
  static const tintShade1 = Color(0x36ABBAC4);
  static const tintShade3 = Color(0xffD8F3C5);
  static const white = Color(0xFFFFFFFF);
  static const white11 = Color(0x1CFFFFFF);
  static const white20 = Color(0x33E2ECFF);
  static const black = Color(0xFF010101);
  static const textDark = Color(0xFF242424);
  static const subtitleGrey = Color(0xFF919195);
  static const shade2 = Color(0xFF93B2F0);
  static const offWhite = Color(0xFFF8F8F8);
  static const inactiveBorder = Color(0xFFD9DADB);
  static const border = Color(0xFFF5F5F5);
  static const danger = Color(0xFFDE0101);
  static const pending = Color(0xFFEA8406);
  static const fade = Color(0xFFD9DADB);
  static const shade3 = Color(0xFFABBAC4);
  static const flora = Color(0xFF919195);
  static const fiat = Color(0xFF54534A);
  static const tertiary = Color(0xFFEDEDED);
  static const background = Color(0xFFE0E3EF);
  static const success = Color(0xFF007E13);
  static const backgroundPale = Color(0xFFF1F4FB);
}

extension ThemeColors on BuildContext {
  Color get _surface => Theme.of(this).colorScheme.surface;
  Brightness get _brightness => Theme.of(this).brightness;
  bool get _isDark => _brightness == Brightness.dark;

  Color get surface => _surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get scaffoldBg => _isDark ? const Color(0xFF11111B) : AppColors.background;
  Color get cardBg => _isDark ? const Color(0xFF1E1E2E) : AppColors.white;
  Color get textPrimary => _isDark ? const Color(0xFFE0E0E0) : AppColors.black;
  Color get textSecondary => _isDark ? const Color(0xFF93939F) : AppColors.subtitleGrey;
  Color get textTertiary => _isDark ? const Color(0xFF6E6E7A) : AppColors.flora;
  Color get divider => _isDark ? const Color(0xFF3A3A4C) : AppColors.offWhite;
  Color get border => _isDark ? const Color(0xFF3A3A4C) : AppColors.tertiary;
  Color get inputBg => _isDark ? const Color(0xFF2A2A3C) : AppColors.white;
  Color get avatarBg => _isDark ? const Color(0xFF2A2A3C) : AppColors.tintShade3;
  Color get appBarOverlay => _isDark
      ? AppColors.white.withValues(alpha: 0.08)
      : AppColors.white.withValues(alpha: 0.15);
  Color get navBarBg => _isDark ? const Color(0xFF1E1E2E) : const Color(0xFFECEDF1);
}

class AppTheme {
  static ThemeData get light {
    final textTheme = GoogleFonts.mulishTextTheme();

    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.tint,
        surface: AppColors.white,
        error: AppColors.danger,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.black,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.flora,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.flora,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mulish(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.offWhite,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.flora,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get dark {
    final textTheme = GoogleFonts.mulishTextTheme(
      ThemeData.dark().textTheme,
    );

    const surface = Color(0xFF1E1E2E);
    const background = Color(0xFF11111B);
    const textPrimary = Color(0xFFE0E0E0);
    const textSecondary = Color(0xFF93939F);
    const border = Color(0xFF3A3A4C);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.tint,
        surface: surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mulish(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.tint,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerColor: border,
      useMaterial3: true,
    );
  }
}
