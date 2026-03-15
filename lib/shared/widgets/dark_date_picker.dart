import 'package:flutter/material.dart';
import 'package:luna/core/theme/app_colors.dart';

Future<DateTime?> showDarkDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? now.subtract(const Duration(days: 1)),
    firstDate: firstDate ?? now.subtract(const Duration(days: 365 * 2)),
    lastDate: lastDate ?? now,
    builder: (ctx, child) => Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.phaseMenstrual,
          onPrimary: Colors.white,
          surface: AppColors.sheetSurface,
          onSurface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.sheetSurface),
      ),
      child: child!,
    ),
  );
}
