import 'package:flutter_test/flutter_test.dart';
import 'package:luna/features/cycle/domain/cycle_predictor.dart';

void main() {
  int predict(List<int> lengths, {int minValid = 21, int maxValid = 35}) =>
      CyclePredictor.predictNextCycleLength(lengths, minValid: minValid, maxValid: maxValid);

  test('no history falls back to 28', () {
    expect(predict([]), 28);
  });

  test('one or two cycles use a plain average', () {
    expect(predict([27]), 27);
    expect(predict([26, 30]), 28);
  });

  test('three to six cycles weight recent cycles more', () {
    expect(predict([26, 28, 30]), 29);
    expect(predict([30, 28, 26]), 27);
  });

  test('only the last four cycles count', () {
    expect(predict([20, 20, 30, 30, 30, 30]), 30);
  });

  test('seven or more cycles drop values outside the valid range', () {
    expect(predict([28, 28, 28, 28, 28, 28, 60]), 28);
  });

  test('seven or more cycles drop statistical outliers inside the valid range', () {
    expect(predict([28, 28, 28, 28, 28, 28, 28, 35]), 28);
  });

  test('falls back to all values when every cycle is outside the valid range', () {
    expect(predict([40, 40, 40, 40, 40, 40, 40]), 40);
  });

  test('period-length bounds trim a long period', () {
    expect(predict([5, 5, 5, 5, 5, 5, 12], minValid: 2, maxValid: 10), 5);
  });
}
