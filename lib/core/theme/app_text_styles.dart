import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heroNumber => GoogleFonts.playfairDisplay(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1,
      );

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

  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get titleLarge => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white.withValues(alpha: 0.9),
      );

  static TextStyle titleSmall({FontWeight fontWeight = FontWeight.w600}) => GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: fontWeight,
        color: Colors.white,
      );

  static TextStyle get monthLabel => GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.8),
        letterSpacing: 0.5,
      );
}
