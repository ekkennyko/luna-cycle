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

  /// Current day within the cycle (1-based, where 1 = first day of period).
  final int dayOfCycle;

  final int cycleLength;

  /// Days remaining until the next expected period. Negative when overdue.
  final int daysUntilNextPeriod;

  final DateTime nextPeriodDate;
  final DateTime ovulationDate;

  /// Five days before ovulation through one day after.
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
  }) {
    final start = DateTime.utc(periodStart.year, periodStart.month, periodStart.day);
    final now = DateTime.utc(today.year, today.month, today.day);

    final dayOfCycle = now.difference(start).inDays + 1;

    final ovDay = cycleLength - 14;

    final CyclePhase phase;
    if (dayOfCycle <= periodLength) {
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

  static String phaseName(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => 'Menstrual',
        CyclePhase.follicular => 'Follicular',
        CyclePhase.ovulation => 'Ovulation',
        CyclePhase.luteal => 'Luteal',
      };

  static String phaseTip(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => 'Your body is releasing. Rest, use warmth, and be gentle with yourself.',
        CyclePhase.follicular => 'Estrogen is rising — your energy and creativity are building.',
        CyclePhase.ovulation => 'Peak energy and confidence! Ideal for social events and exercise.',
        CyclePhase.luteal => 'Progesterone peaks then drops. Prioritize sleep and self-care.',
      };
}
