import 'package:flutter/material.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/theme/app_colors.dart';

const _sheetGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF1E1118), Color(0xFF150D12)],
);

const _sheetBorderSide = BorderSide(color: Color(0x0FFFFFFF));

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.darkHint,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: _sheetGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        border: Border(
          top: _sheetBorderSide,
          left: _sheetBorderSide,
          right: _sheetBorderSide,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
