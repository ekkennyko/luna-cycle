import 'package:flutter/material.dart';
import 'package:luna/core/theme/app_colors.dart';

class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final glowColor = color ?? AppColors.phaseMenstrual;
    return Positioned(
      top: -60,
      left: 0,
      right: 0,
      height: 300,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 0.8,
            colors: [glowColor.withValues(alpha: 0.09), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
