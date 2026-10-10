import 'package:flutter_test/flutter_test.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';

void main() {
  group('phaseForDay', () {
    CyclePhase phase(int day, {int periodLength = 5, int cycleLength = 28}) =>
        CyclePhaseCalculator.phaseForDay(dayOfCycle: day, periodLength: periodLength, cycleLength: cycleLength);

    test('28-day cycle boundaries', () {
      expect(phase(1), CyclePhase.menstrual);
      expect(phase(5), CyclePhase.menstrual);
      expect(phase(6), CyclePhase.follicular);
      expect(phase(11), CyclePhase.follicular);
      expect(phase(12), CyclePhase.ovulation);
      expect(phase(16), CyclePhase.ovulation);
      expect(phase(17), CyclePhase.luteal);
      expect(phase(28), CyclePhase.luteal);
    });

    test('luteal continues when the cycle runs past its expected length', () {
      expect(phase(29), CyclePhase.luteal);
      expect(phase(45), CyclePhase.luteal);
    });

    test('ovulation shifts with cycle length', () {
      expect(phase(16, cycleLength: 32), CyclePhase.ovulation);
      expect(phase(15, cycleLength: 32), CyclePhase.follicular);
      expect(phase(21, cycleLength: 32), CyclePhase.luteal);
    });

    test('menstrual takes priority over ovulation in a short cycle with a long period', () {
      expect(phase(7, periodLength: 7, cycleLength: 21), CyclePhase.menstrual);
      expect(phase(8, periodLength: 7, cycleLength: 21), CyclePhase.ovulation);
    });
  });

  group('calculate', () {
    final start = DateTime(2026, 3, 1);

    PhaseResult calc(DateTime today, {DateTime? periodEnd, int cycleLength = 28}) =>
        CyclePhaseCalculator.calculate(periodStart: start, cycleLength: cycleLength, today: today, periodEnd: periodEnd);

    test('first day of the period', () {
      final r = calc(DateTime(2026, 3, 1), periodEnd: DateTime(2026, 3, 5));
      expect(r.dayOfCycle, 1);
      expect(r.phase, CyclePhase.menstrual);
      expect(r.daysUntilNextPeriod, 28);
    });

    test('ended period uses its real length', () {
      expect(calc(DateTime(2026, 3, 4), periodEnd: DateTime(2026, 3, 3)).phase, CyclePhase.follicular);
      expect(calc(DateTime(2026, 3, 3), periodEnd: DateTime(2026, 3, 3)).phase, CyclePhase.menstrual);
    });

    test('ongoing period stays menstrual past the usual length', () {
      expect(calc(DateTime(2026, 3, 8)).phase, CyclePhase.menstrual);
    });

    test('next period, ovulation and fertile window dates', () {
      final r = calc(DateTime(2026, 3, 10), periodEnd: DateTime(2026, 3, 5));
      expect(r.nextPeriodDate, DateTime.utc(2026, 3, 29));
      expect(r.ovulationDate, DateTime.utc(2026, 3, 14));
      expect(r.fertileWindow.start, DateTime.utc(2026, 3, 9));
      expect(r.fertileWindow.end, DateTime.utc(2026, 3, 15));
      expect(r.daysUntilNextPeriod, 19);
    });

    test('late period gives negative days until next period', () {
      final r = calc(DateTime(2026, 4, 2), periodEnd: DateTime(2026, 3, 5));
      expect(r.dayOfCycle, 33);
      expect(r.daysUntilNextPeriod, -4);
      expect(r.phase, CyclePhase.luteal);
    });

    test('day count is not affected by a daylight saving change', () {
      final r = CyclePhaseCalculator.calculate(
        periodStart: DateTime(2026, 3, 20),
        cycleLength: 28,
        today: DateTime(2026, 4, 5),
        periodEnd: DateTime(2026, 3, 24),
      );
      expect(r.dayOfCycle, 17);
    });

    test('UTC-stored dates resolve to the same local calendar day', () {
      final r = CyclePhaseCalculator.calculate(
        periodStart: DateTime(2026, 3, 1).toUtc(),
        cycleLength: 28,
        today: DateTime(2026, 3, 2, 23, 30),
        periodEnd: DateTime(2026, 3, 5).toUtc(),
      );
      expect(r.dayOfCycle, 2);
    });
  });
}
