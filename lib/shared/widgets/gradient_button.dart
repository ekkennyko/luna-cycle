import 'package:flutter/material.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.secondaryColor,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.fontSize = 15,
    this.borderRadius,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  /// Second gradient stop. Defaults to [color] at 80 % opacity.
  final Color? secondaryColor;

  final bool enabled;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  /// Defaults to [AppRadius.button].
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.button;
    final end = secondaryColor ?? color.withValues(alpha: 0.8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, end],
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.white : AppColors.darkHint,
            ),
          ),
        ),
      ),
    );
  }
}
