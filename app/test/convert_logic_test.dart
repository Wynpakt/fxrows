import 'package:flutter_test/flutter_test.dart';
import 'package:fxboard/data/rates/rate_snapshot.dart';
import 'package:fxboard/features/convert/expression.dart';

void main() {
  group('tryEvaluateExpression', () {
    test('plain numbers', () {
      expect(tryEvaluateExpression('100'), 100);
      expect(tryEvaluateExpression('12,5'), 12.5);
      expect(tryEvaluateExpression('-3'), -3);
    });

    test('addition and subtraction', () {
      expect(tryEvaluateExpression('100+50'), 150);
      expect(tryEvaluateExpression('200-30'), 170);
      expect(tryEvaluateExpression('10 + 5 - 2'), 13);
    });

    test('multiply divide and precedence', () {
      expect(tryEvaluateExpression('2*3+4'), 10);
      expect(tryEvaluateExpression('(2+3)*4'), 20);
      expect(tryEvaluateExpression('100/4'), 25);
    });

    test('invalid returns null', () {
      expect(tryEvaluateExpression(''), isNull);
      expect(tryEvaluateExpression('1+'), isNull);
      expect(tryEvaluateExpression('abc'), isNull);
    });
  });

  group('RateSnapshot.convert', () {
    final snap = RateSnapshot.dummy();

    test('identity', () {
      expect(snap.convert(amount: 50, from: 'EUR', to: 'EUR'), 50);
    });

    test('EUR to USD', () {
      expect(
        snap.convert(amount: 100, from: 'EUR', to: 'USD'),
        closeTo(113.77, 0.001),
      );
    });

    test('USD to GBP via cross', () {
      final usdToGbp = snap.convert(amount: 100, from: 'USD', to: 'GBP');
      expect(usdToGbp, closeTo(100 * 0.8539 / 1.1377, 0.001));
    });
  });
}
