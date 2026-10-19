import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/rate_snapshot.dart';
import 'package:fxrows/data/rates/rate_snapshot_cache.dart';
import 'package:fxrows/data/rates/rates_provider.dart';
import 'package:fxrows/data/rates/rates_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  RateSnapshot cachedSnap({
    String asOf = '2026-07-24',
    DateTime? fetchedAt,
  }) {
    return RateSnapshot(
      base: 'EUR',
      asOf: asOf,
      fetchedAt: fetchedAt ?? DateTime.utc(2026, 7, 24, 15),
      source: 'Frankfurter',
      attribution: 'test',
      disclaimer: 'test',
      rates: const {'EUR': 1, 'USD': 1.1, 'GBP': 0.85},
    );
  }

  http.Client failingClient() => MockClient((_) async {
        throw Exception('offline');
      });

  group('RatesRepository.fetch offline cache', () {
    late RateSnapshotCache cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cache = RateSnapshotCache();
    });

    test('returns disk cache when network fails (forceRefresh false)', () async {
      final snap = cachedSnap();
      await cache.save(RatesProviderId.frankfurter, snap);

      final repo = RatesRepository(
        client: failingClient(),
        cache: cache,
        clock: () => DateTime.utc(2026, 7, 26, 12), // Sunday → needs network
      );

      final result = await repo.fetch(
        providerId: RatesProviderId.frankfurter,
        forceRefresh: false,
      );
      expect(result.source, 'Frankfurter');
      expect(result.rates['USD'], 1.1);
    });

    test('returns disk cache when network fails (forceRefresh true)', () async {
      final snap = cachedSnap();
      await cache.save(RatesProviderId.frankfurter, snap);

      final repo = RatesRepository(
        client: failingClient(),
        cache: cache,
        clock: () => DateTime.utc(2026, 7, 26, 12),
      );

      final result = await repo.fetch(
        providerId: RatesProviderId.frankfurter,
        forceRefresh: true,
      );
      expect(result.source, 'Frankfurter');
      expect(result.asOf, '2026-07-24');
    });

    test('rethrows when network fails and cache is empty', () async {
      final repo = RatesRepository(
        client: failingClient(),
        cache: cache,
        clock: () => DateTime.utc(2026, 7, 26, 12),
      );

      expect(
        () => repo.fetch(
          providerId: RatesProviderId.frankfurter,
          forceRefresh: false,
        ),
        throwsA(isA<RatesException>()),
      );
    });

    test('skips network when weekend Friday cache is warm', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('[]', 500);
      });
      final snap = cachedSnap(
        asOf: '2026-07-24',
        fetchedAt: DateTime.utc(2026, 7, 25, 18), // within maxAge of Sunday noon
      );
      await cache.save(RatesProviderId.frankfurter, snap);

      final repo = RatesRepository(
        client: client,
        cache: cache,
        clock: () => DateTime.utc(2026, 7, 26, 12), // Sunday
      );

      final result = await repo.fetch(
        providerId: RatesProviderId.frankfurter,
        forceRefresh: false,
      );
      expect(calls, 0);
      expect(result.asOf, '2026-07-24');
    });
  });
}
