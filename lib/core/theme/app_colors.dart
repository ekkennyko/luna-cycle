import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — soft rose/mauve
  static const primary = Color(0xFFD4667A);
  static const primaryLight = Color(0xFFEA9BAB);
  static const primaryDark = Color(0xFFB04060);

  // Secondary — warm lavender
  static const secondary = Color(0xFF9B7EC8);
  static const secondaryLight = Color(0xFFBCA8E0);

  // Cycle phase colours
  static const phaseMenstrual = Color(0xFFE05A7A);
  static const phaseFolicular = Color(0xFFF4A261);
  static const phaseOvulation = Color(0xFFA8DADC);
  static const phaseLuteal = Color(0xFF9B72CF);

  // App background
  static const appBackground = Color(0xFF120A0A);

  // Neutral
  static const surface = Color(0xFFFDF6F8);
  static const surfaceVariant = Color(0xFFF3E8EC);
  static const outline = Color(0xFFD8C0C8);

  // Text
  static const textPrimary = Color(0xFF2D1F24);
  static const textSecondary = Color(0xFF7A5C66);
  static const textDisabled = Color(0xFFB8A0A8);

  // Semantic
  static const success = Color(0xFF5BAD8A);
  static const warning = Color(0xFFF0A44A);
  static const error = Color(0xFFCF4545);

  // Dark theme surfaces
  static const surfaceDark = Color(0xFF1E1418);
  static const surfaceVariantDark = Color(0xFF2D1F24);

  // Sheet / dialog surfaces
  static const sheetSurface = Color(0xFF1E1118);
  static const sheetSurfaceEnd = Color(0xFF150D12);

  // Nav bar
  static const navBarBg = Color(0xF2120A0A);
  static const navBarBorder = Color(0x0FFFFFFF);

  // Phase background tints (low alpha for calendar / cards)
  static const phaseMenstrualBg = Color(0x1FE05A7A);
  static const phaseFolicularBg = Color(0x1AF4A261);
  static const phaseOvulationBg = Color(0x1AA8DADC);
  static const phaseLutealBg = Color(0x1A9B72CF);
}
