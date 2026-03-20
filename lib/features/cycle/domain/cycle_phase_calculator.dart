enum CyclePhase { menstrual, follicular, ovulation, luteal }

class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class PhaseResult {
  const PhaseResult({
    required this.phase,
    required this.dayOfCycle,
    required this.cycleLength,
    required this.daysUntilNextPeriod,
    required this.nextPeriodDate,
    required this.ovulationDate,
    required this.fertileWindow,
  });

  final CyclePhase phase;

  final int dayOfCycle;

  final int cycleLength;

  /// Days remaining until the next expected period. Negative when overdue.
  final int daysUntilNextPeriod;

  final DateTime nextPeriodDate;
  final DateTime ovulationDate;

  final DateRange fertileWindow;
}

class CyclePhaseCalculator {
  CyclePhaseCalculator._();

  /// Calculates the current cycle phase and related dates for [today].
  ///
  /// Phase boundaries based on a fixed 14-day luteal phase:
  ///   - Menstrual:  day 1 → [periodLength]
  ///   - Follicular: day [periodLength]+1 → ovulation day − 3
  ///   - Ovulation:  ovulation day − 2 → ovulation day + 2
  ///   - Luteal:     ovulation day + 3 → [cycleLength]
  ///
  /// Ovulation day = [cycleLength] − 14 (standard luteal phase length).
  static PhaseResult calculate({
    required DateTime periodStart,
    required int periodLength,
    required int cycleLength,
    required DateTime today,
    DateTime? periodEnd,
  }) {
    final s = periodStart.toLocal();
    final t = today.toLocal();
    final start = DateTime.utc(s.year, s.month, s.day);
    final now = DateTime.utc(t.year, t.month, t.day);

    final dayOfCycle = now.difference(start).inDays + 1;

    final int actualPeriodLength;
    if (periodEnd != null) {
      final e = periodEnd.toLocal();
      final endNorm = DateTime.utc(e.year, e.month, e.day);
      actualPeriodLength = endNorm.difference(start).inDays;
    } else {
      // Period is still active — menstrual phase extends through current day.
      actualPeriodLength = dayOfCycle;
    }

    final ovDay = cycleLength - 14;

    final CyclePhase phase;
    if (dayOfCycle <= actualPeriodLength) {
      phase = CyclePhase.menstrual;
    } else if (dayOfCycle < ovDay - 2) {
      phase = CyclePhase.follicular;
    } else if (dayOfCycle <= ovDay + 2) {
      phase = CyclePhase.ovulation;
    } else {
      phase = CyclePhase.luteal;
    }

    final nextPeriodDate = start.add(Duration(days: cycleLength));
    final daysUntilNextPeriod = nextPeriodDate.difference(now).inDays;

    final ovulationDate = start.add(Duration(days: ovDay - 1));

    final fertileWindow = DateRange(
      start: ovulationDate.subtract(const Duration(days: 5)),
      end: ovulationDate.add(const Duration(days: 1)),
    );

    return PhaseResult(
      phase: phase,
      dayOfCycle: dayOfCycle,
      cycleLength: cycleLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      nextPeriodDate: nextPeriodDate,
      ovulationDate: ovulationDate,
      fertileWindow: fertileWindow,
    );
  }

  static String phaseName(CyclePhase phase) => phase.name;
}
