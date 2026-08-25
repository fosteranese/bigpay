import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class AppTypography {
  AppTypography._();

  /// Display 1 — 28px Bold (GHS balance, hero numbers)
  static TextStyle get display1 => GoogleFonts.mulish(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.white,
  );

  /// Display 2 — 22px Bold (page titles, large headings)
  static TextStyle get display2 => GoogleFonts.mulish(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.black,
  );

  /// Header 1 — 20px Bold (section titles like "Select Payment Mode")
  static TextStyle get header1 => GoogleFonts.mulish(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.2,
    color: AppColors.black,
  );

  /// Header 2 — 18px Bold (secondary section headers)
  static TextStyle get header2 => GoogleFonts.mulish(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.black,
  );

  /// Header 3 — 16px Bold (card titles, "Recent Activities", "Transactions")
  static TextStyle get header3 => GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.black,
  );

  /// Header 4 — 14px Bold (sub-section titles, "See all" links)
  static TextStyle get header4 => GoogleFonts.mulish(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.black,
  );

  /// P1 — 16px Regular (body text)
  static TextStyle get p1 => GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.black,
  );

  /// P1 Medium — 16px w500 (balance amounts, emphasized body)
  static TextStyle get p1Medium => GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.black,
  );

  /// P1 Bold — 16px Bold (emphasized body)
  static TextStyle get p1Bold => GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.black,
  );

  /// Small details — 14px Regular (secondary info, subtitles)
  static TextStyle get smallDetails => GoogleFonts.mulish(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.subtitleGrey,
  );

  /// Small details Medium — 14px w600
  static TextStyle get smallDetailsMedium => GoogleFonts.mulish(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.black,
  );

  /// Small details Bold — 14px Bold (action links, "See all")
  static TextStyle get smallDetailsBold => GoogleFonts.mulish(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.black,
  );

  /// Caption — 13px Regular (tiny labels like account numbers, tab labels)
  static TextStyle get caption => GoogleFonts.mulish(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.flora,
  );

  /// Caption Medium — 13px w500 (balance visibility toggle, form hints)
  static TextStyle get captionMedium => GoogleFonts.mulish(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.black,
  );

  /// Caption Bold — 13px Bold (emphasized labels, prices)
  static TextStyle get captionBold => GoogleFonts.mulish(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.black,
  );

  /// Caption Semibold — 13px w600 (menu items, action labels)
  static TextStyle get captionSemibold => GoogleFonts.mulish(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.black,
  );

  /// Small — 12px Regular (status text, secondary labels)
  static TextStyle get small => GoogleFonts.mulish(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.subtitleGrey,
  );

  /// Small Medium — 12px w500 (welcome prefix, form labels)
  static TextStyle get smallMedium => GoogleFonts.mulish(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.black,
  );

  /// Small Bold — 12px Bold (user name, important labels)
  static TextStyle get smallBold => GoogleFonts.mulish(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.black,
  );

  /// Menu Links — 13px w600 (bottom navigation active labels)
  static TextStyle get menuLinks => GoogleFonts.mulish(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.primary,
  );

  /// Buttons — 16px w700 (primary button text)
  static TextStyle get buttons => GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.white,
  );

  /// Form labels — 14px w600 (input field labels)
  static TextStyle get formLabels => GoogleFonts.mulish(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.black,
  );
}

extension ThemeText on BuildContext {
  Color get _primary => Theme.of(this).colorScheme.onSurface;
  Color get _secondary => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF93939F)
      : AppColors.subtitleGrey;
  Color get _tertiary => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF6E6E7A)
      : AppColors.flora;

  TextStyle get display1 => AppTypography.display1.copyWith(color: _primary);
  TextStyle get display2 => AppTypography.display2.copyWith(color: _primary);
  TextStyle get header1 => AppTypography.header1.copyWith(color: _primary);
  TextStyle get header2 => AppTypography.header2.copyWith(color: _primary);
  TextStyle get header3 => AppTypography.header3.copyWith(color: _primary);
  TextStyle get header4 => AppTypography.header4.copyWith(color: _primary);
  TextStyle get p1 => AppTypography.p1.copyWith(color: _primary);
  TextStyle get p1Medium => AppTypography.p1Medium.copyWith(color: _primary);
  TextStyle get p1Bold => AppTypography.p1Bold.copyWith(color: _primary);
  TextStyle get smallDetails =>
      AppTypography.smallDetails.copyWith(color: _secondary);
  TextStyle get smallDetailsMedium =>
      AppTypography.smallDetailsMedium.copyWith(color: _primary);
  TextStyle get smallDetailsBold =>
      AppTypography.smallDetailsBold.copyWith(color: _primary);
  TextStyle get caption => AppTypography.caption.copyWith(color: _tertiary);
  TextStyle get captionMedium =>
      AppTypography.captionMedium.copyWith(color: _primary);
  TextStyle get captionBold =>
      AppTypography.captionBold.copyWith(color: _primary);
  TextStyle get captionSemibold =>
      AppTypography.captionSemibold.copyWith(color: _primary);
  TextStyle get small => AppTypography.small.copyWith(color: _secondary);
  TextStyle get smallMedium =>
      AppTypography.smallMedium.copyWith(color: _primary);
  TextStyle get smallBold => AppTypography.smallBold.copyWith(color: _primary);
  TextStyle get formLabels =>
      AppTypography.formLabels.copyWith(color: _primary);
  TextStyle get buttons => AppTypography.buttons.copyWith(color: _primary);
  TextStyle get menuLinks => AppTypography.menuLinks.copyWith(color: _primary);
}
