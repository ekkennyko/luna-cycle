import 'package:flutter/material.dart';

ThemeData appDatePickerTheme(Color accentColor) {
  return ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      onPrimary: Colors.white,
      surface: const Color(0xFF1E1118),
      onSurface: Colors.white,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1118)),
  );
}
