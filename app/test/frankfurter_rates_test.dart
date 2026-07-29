import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/ecb_refresh_policy.dart';
import 'package:fxrows/data/rates/parse_frankfurter.dart';
import 'package:fxrows/data/rates/rate_snapshot.dart';
import 'package:fxrows/data/rates/rate_snapshot_cache.dart';
import 'package:fxrows/data/rates/rates_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sampleFrankfurterJson = '''
[
  {"date":"2026-07-29","base":"EUR","quote":"USD","rate":1.1392,"providers":[{"key":"ECB","date":"2026-07-28","rate":1.1367},{"key":"NBG","date":"2026-07-29","rate":1.1359}]},
  {"date":"2026-07-29","base":"EUR","quote":"GEL","rate":2.9871,"providers":[{"key":"NBG","date":"2026-07-29","rate":2.9937}]},
  {"date":"2026-07-28","base":"EUR","quote":"GBP","rate":0.85619}
]
''';

void main() {
  group('parseFrankfurterRatesJson', () {
    test('parses flat array, max asOf, base, and provider keys', () {
      final parsed = parseFrankfurterRatesJson(sampleFrankfurterJson);
      expect(parsed.base, 'EUR');
      expect(parsed.asOf, '2026-07-29');
      expect(parsed.rates['EUR'], 1.0);
      expect(parsed.rates['USD'], 1.1392);
      expect(parsed.rates['GEL'], 2.9871);
      expect(parsed.rates['GBP'], 0.85619);
      expect(parsed.providerKeys, containsAll(['ECB', 'NBG']));
    });

    test('works without expand=providers', () {
      const bare = '''
[{"date":"2026-07-29","base":"EUR","quote":"CHF","rate":0.93}]
''';
      final parsed = parseFrankfurterRatesJson(bare);
      expect(parsed.rates['CHF'], 0.93);
      expect(parsed.providerKeys, isEmpty);
    });

    test('rejects empty array', () {
      expect(
        () => parseFrankfurterRatesJson('[]'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('shouldRefreshDailyRates', () {
    RateSnapshot snap({required String asOf, required DateTime fetchedAt}) {
      return RateSnapshot(
        base: 'EUR',
        asOf: asOf,
        fetchedAt: fetchedAt,
        source: 'Frankfurter',
        attribution: '',
        disclaimer: '',
        rates: const {'EUR': 1, 'USD': 1.1},
      );
    }

    test('refreshes when asOf is before today UTC', () {
      expect(
        shouldRefreshDailyRates(
          cached: snap(
            asOf: '2026-07-28',
            fetchedAt: DateTime.utc(2026, 7, 28, 18),
          ),
          nowUtc: DateTime.utc(2026, 7, 29, 12),
        ),
        isTrue,
      );
    });

    test('keeps cache when asOf is today and fresh', () {
      expect(
        shouldRefreshDailyRates(
          cached: snap(
            asOf: '2026-07-29',
            fetchedAt: DateTime.utc(2026, 7, 29, 8),
          ),
          nowUtc: DateTime.utc(2026, 7, 29, 12),
        ),
        isFalse,
      );
    });

    test('refreshes after maxAge even if asOf is today', () {
      expect(
        shouldRefreshDailyRates(
          cached: snap(
            asOf: '2026-07-29',
            fetchedAt: DateTime.utc(2026, 7, 28, 10),
          ),
          nowUtc: DateTime.utc(2026, 7, 29, 12),
        ),
        isTrue,
      );
    });
  });

  group('RateSnapshotCache frankfurter key', () {
    test('round-trips under frankfurter provider id', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = RateSnapshotCache();
      final original = RateSnapshot(
        base: 'EUR',
        asOf: '2026-07-29',
        fetchedAt: DateTime.utc(2026, 7, 29, 12),
        source: 'Frankfurter',
        attribution: 'test',
        disclaimer: 'test',
        rates: const {'EUR': 1, 'GEL': 2.9},
      );
      await cache.save(RatesProviderId.frankfurter, original);
      final loaded = await cache.load(RatesProviderId.frankfurter);
      expect(loaded?.rates['GEL'], 2.9);
      expect(loaded?.source, 'Frankfurter');
    });
  });
}
