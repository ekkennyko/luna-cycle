import 'dart:math';

class CyclePredictor {
  CyclePredictor._();

  /// Predicts next cycle length from historical cycle lengths (oldest → newest).
  /// Uses simple average for ≤2 cycles, weighted average for 3-6,
  /// and trimmed weighted average for 7+.
  /// [minValid]/[maxValid] bound the outlier trim; pass period-length bounds
  /// when predicting period length instead of cycle length.
  static int predictNextCycleLength(
    List<int> cycleLengths, {
    int minValid = 21,
    int maxValid = 35,
  }) {
    if (cycleLengths.isEmpty) return 28;

    if (cycleLengths.length <= 2) {
      return (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();
    }

    if (cycleLengths.length <= 6) {
      return _weightedAverage(cycleLengths);
    }

    final trimmed = _trimOutliers(cycleLengths, minValid, maxValid);
    if (trimmed.isEmpty) {
      return _weightedAverage(cycleLengths);
    }
    return _weightedAverage(trimmed);
  }

  static int _weightedAverage(List<int> cycles) {
    final weights = _getWeights(cycles.length.clamp(1, 4));
    final recent = cycles.length > 4 ? cycles.sublist(cycles.length - 4) : cycles;
    double weighted = 0;
    for (int i = 0; i < recent.length; i++) {
      weighted += recent[recent.length - 1 - i] * weights[i];
    }
    return weighted.round();
  }

  static List<double> _getWeights(int count) => switch (count) {
        1 => [1.0],
        2 => [0.6, 0.4],
        3 => [0.5, 0.3, 0.2],
        _ => [0.4, 0.3, 0.2, 0.1],
      };

  static List<int> _trimOutliers(List<int> cycles, int minValid, int maxValid) {
    final filtered = cycles.where((c) => c >= minValid && c <= maxValid).toList();
    if (filtered.length < 3) return filtered;

    final mean = filtered.reduce((a, b) => a + b) / filtered.length;
    final variance = filtered.map((c) => (c - mean) * (c - mean)).reduce((a, b) => a + b) / filtered.length;
    final std = sqrt(variance);

    return filtered.where((c) => (c - mean).abs() <= 2 * std).toList();
  }
}
