import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/open_exchange_rates_provider.dart';
import 'package:fxrows/data/rates/rate_snapshot.dart';
import 'package:fxrows/features/convert/currency_flag.dart';
import 'package:fxrows/features/convert/expression.dart';

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

    test('div by zero and unary after op', () {
      expect(tryEvaluateExpression('1/0'), isNull);
      expect(tryEvaluateExpression('2*-3'), -6);
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

    test('mergedWith adds custom rates', () {
      final merged = snap.mergedWith({'BTC': 0.000012});
      expect(merged.rates.containsKey('BTC'), isTrue);
      expect(
        merged.convert(amount: 1, from: 'EUR', to: 'BTC'),
        closeTo(0.000012, 1e-12),
      );
      // Original unchanged
      expect(snap.rates.containsKey('BTC'), isFalse);
    });
  });

  group('currencyLabel', () {
    test('uppercases codes without emoji', () {
      expect(currencyLabel('eur'), 'EUR');
      expect(currencyLabel('USD'), 'USD');
      expect(currencyLabel('gel'), 'GEL');
    });
  });

  group('parseOpenExchangeRatesLatest', () {
    test('maps USD-base payload', () {
      final snap = parseOpenExchangeRatesLatest({
        'disclaimer': 'Sample disclaimer',
        'license': 'https://example.com/license',
        'timestamp': 1449877801,
        'base': 'USD',
        'rates': {
          'USD': 1,
          'EUR': 0.92,
          'GBP': 0.75,
          'GEL': 2.7,
        },
      });
      expect(snap.base, 'USD');
      expect(snap.source, 'Open Exchange Rates');
      expect(snap.asOf, '2015-12-11');
      expect(snap.rates['EUR'], 0.92);
      expect(
        snap.convert(amount: 100, from: 'USD', to: 'EUR'),
        closeTo(92, 0.001),
      );
      expect(
        snap.convert(amount: 100, from: 'EUR', to: 'GBP'),
        closeTo(100 * 0.75 / 0.92, 0.001),
      );
    });
  });
}
