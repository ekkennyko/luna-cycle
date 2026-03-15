import 'package:flutter/material.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';

class PhaseStyle {
  const PhaseStyle({
    required this.name,
    required this.color,
    required this.bgColor,
    required this.tip,
  });

  final String name;
  final Color color;
  final Color bgColor;
  final String tip;

  static const menstrual = PhaseStyle(
    name: 'Menstrual',
    color: AppColors.phaseMenstrual,
    bgColor: AppColors.phaseMenstrualBg,
    tip: 'Your body is releasing. Rest, use warmth, and be gentle with yourself. Iron-rich foods like spinach and lentils can help replenish.',
  );

  static const follicular = PhaseStyle(
    name: 'Follicular',
    color: AppColors.phaseFolicular,
    bgColor: AppColors.phaseFolicularBg,
    tip: 'Estrogen is rising — your energy and creativity are building. Great time to start new projects and try challenging workouts.',
  );

  static const ovulation = PhaseStyle(
    name: 'Ovulation',
    color: AppColors.phaseOvulation,
    bgColor: AppColors.phaseOvulationBg,
    tip: "Peak energy and confidence! You're magnetic right now. Ideal for social events, big presentations, and high-intensity exercise.",
  );

  static const luteal = PhaseStyle(
    name: 'Luteal',
    color: AppColors.phaseLuteal,
    bgColor: AppColors.phaseLutealBg,
    tip: 'Progesterone peaks then drops. Prioritize sleep, magnesium-rich foods, and reduce caffeine. Self-care is not optional.',
  );

  static PhaseStyle forPhase(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => menstrual,
        CyclePhase.follicular => follicular,
        CyclePhase.ovulation => ovulation,
        CyclePhase.luteal => luteal,
      };

  static Color colorFor(CyclePhase phase) => forPhase(phase).color;

  static Color bgColorFor(CyclePhase phase) => forPhase(phase).bgColor;
}
