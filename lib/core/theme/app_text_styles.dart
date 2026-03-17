import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  /// 72px bold — hero cycle day number.
  static TextStyle get heroNumber => GoogleFonts.playfairDisplay(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1,
      );

  /// 28px — page headings.
  static TextStyle displayLarge({
    Color color = Colors.white,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// 26px — section headings.
  static TextStyle displayMedium({
    Color color = Colors.white,
    double? height,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
      );

  /// 24px — onboarding step titles.
  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  /// 20px — dialog / sheet headings.
  static TextStyle get titleLarge => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  /// 18px — brand / logo text.
  static TextStyle titleMedium({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white.withValues(alpha: 0.9),
      );

  /// 17px — sheet / section titles.
  static TextStyle titleSmall({FontWeight fontWeight = FontWeight.w600}) => GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: fontWeight,
        color: Colors.white,
      );

  /// 16px — calendar month labels.
  static TextStyle get monthLabel => GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      );
}
