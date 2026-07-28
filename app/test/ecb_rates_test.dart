import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/ecb_refresh_policy.dart';
import 'package:fxrows/data/rates/parse_ecb.dart';
import 'package:fxrows/data/rates/rate_snapshot.dart';
import 'package:fxrows/data/rates/rate_snapshot_cache.dart';
import 'package:fxrows/data/rates/rates_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sampleXml = '''<?xml version="1.0" encoding="UTF-8"?>
<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
  <gesmes:subject>Reference rates</gesmes:subject>
  <Cube>
    <Cube time="2026-07-24">
      <Cube currency="USD" rate="1.1377"/>
      <Cube currency="GBP" rate="0.8539"/>
      <Cube currency="CHF" rate="0.9302"/>
    </Cube>
  </Cube>
</gesmes:Envelope>''';

void main() {
  group('parseEcbDailyXml', () {
    test('parses date and rates including EUR=1', () {
      final parsed = parseEcbDailyXml(sampleXml);
      expect(parsed.asOf, '2026-07-24');
      expect(parsed.rates['EUR'], 1);
      expect(parsed.rates['USD'], 1.1377);
      expect(parsed.rates['GBP'], 0.8539);
      expect(parsed.rates['CHF'], 0.9302);
    });

    test('rejects missing time', () {
      expect(
        () => parseEcbDailyXml("<Cube currency='USD' rate='1'/>"),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('expectedEcbAsOfDate', () {
    test('weekday after publish window expects today', () {
      // Friday 2026-07-24 17:00 CEST (UTC+2 in July)
      final cet = DateTime(2026, 7, 24, 17, 0);
      expect(expectedEcbAsOfDate(cet), DateTime(2026, 7, 24));
    });

    test('weekday before publish window expects previous business day', () {
      final cet = DateTime(2026, 7, 24, 10, 0);
      expect(expectedEcbAsOfDate(cet), DateTime(2026, 7, 23));
    });

    test('Saturday resolves to Friday', () {
      final cet = DateTime(2026, 7, 25, 12, 0);
      expect(expectedEcbAsOfDate(cet), DateTime(2026, 7, 24));
    });

    test('Monday morning expects previous Friday', () {
      final cet = DateTime(2026, 7, 27, 10, 0);
      expect(expectedEcbAsOfDate(cet), DateTime(2026, 7, 24));
    });
  });

  group('shouldRefreshEcb', () {
    RateSnapshot snap(String asOf, {DateTime? fetchedAt}) => RateSnapshot(
          base: 'EUR',
          asOf: asOf,
          fetchedAt: fetchedAt ?? DateTime.utc(2026, 7, 24, 15),
          source: 'ECB',
          attribution: 't',
          disclaimer: 't',
          rates: const {'EUR': 1, 'USD': 1.1},
        );

    test('force always refreshes', () {
      expect(
        shouldRefreshEcb(
          cached: snap('2026-07-24'),
          nowUtc: DateTime.utc(2026, 7, 24, 18),
          force: true,
        ),
        isTrue,
      );
    });

    test('null cache refreshes', () {
      expect(
        shouldRefreshEcb(
          cached: null,
          nowUtc: DateTime.utc(2026, 7, 24, 18),
        ),
        isTrue,
      );
    });

    test('fresh as_of after publish does not refresh', () {
      // Friday 18:00 UTC = 20:00 CEST — after publish; as_of is today.
      expect(
        shouldRefreshEcb(
          cached: snap('2026-07-24', fetchedAt: DateTime.utc(2026, 7, 24, 15)),
          nowUtc: DateTime.utc(2026, 7, 24, 18),
        ),
        isFalse,
      );
    });

    test('stale as_of refreshes', () {
      expect(
        shouldRefreshEcb(
          cached: snap('2026-07-22'),
          nowUtc: DateTime.utc(2026, 7, 24, 18),
        ),
        isTrue,
      );
    });

    test('weekend keeps Friday snapshot', () {
      expect(
        shouldRefreshEcb(
          cached: snap('2026-07-24', fetchedAt: DateTime.utc(2026, 7, 24, 15)),
          nowUtc: DateTime.utc(2026, 7, 25, 12), // Saturday
        ),
        isFalse,
      );
    });
  });

  group('shouldRefreshThrottled', () {
    test('respects minAge', () {
      final cached = RateSnapshot(
        base: 'EUR',
        asOf: '2026-07-24',
        fetchedAt: DateTime.utc(2026, 7, 24, 12, 0),
        source: 'ERA',
        attribution: 't',
        disclaimer: 't',
        rates: const {'EUR': 1},
      );
      expect(
        shouldRefreshThrottled(
          cached: cached,
          nowUtc: DateTime.utc(2026, 7, 24, 12, 20),
          minAge: const Duration(minutes: 30),
        ),
        isFalse,
      );
      expect(
        shouldRefreshThrottled(
          cached: cached,
          nowUtc: DateTime.utc(2026, 7, 24, 12, 40),
          minAge: const Duration(minutes: 30),
        ),
        isTrue,
      );
    });
  });

  group('RateSnapshotCache', () {
    test('round-trips snapshot JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = RateSnapshotCache();
      final original = RateSnapshot.dummy();
      await cache.save(RatesProviderId.ecbDirect, original);
      final loaded = await cache.load(RatesProviderId.ecbDirect);
      expect(loaded, isNotNull);
      expect(loaded!.source, original.source);
      expect(loaded.asOf, original.asOf);
      expect(loaded.rates['USD'], original.rates['USD']);
    });
  });

  group('centralEuropeanOffset', () {
    test('July is CEST (+2)', () {
      expect(
        centralEuropeanOffset(DateTime.utc(2026, 7, 15, 12)),
        const Duration(hours: 2),
      );
    });

    test('January is CET (+1)', () {
      expect(
        centralEuropeanOffset(DateTime.utc(2026, 1, 15, 12)),
        const Duration(hours: 1),
      );
    });
  });
}
