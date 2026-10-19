import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/rate_snapshot.dart';
import 'package:fxrows/data/rates/rates_provider.dart';
import 'package:fxrows/data/rates/rates_repository.dart';
import 'package:fxrows/features/convert/convert_controller.dart';
import 'package:fxrows/features/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends RatesRepository {
  _FakeRepo({this.next, this.error, this.cached});

  RateSnapshot? next;
  RateSnapshot? cached;
  Object? error;
  int fetchCount = 0;
  bool? lastForceRefresh;

  @override
  Future<RateSnapshot?> loadCached(RatesProviderId providerId) async => cached;

  @override
  Future<RateSnapshot> fetch({
    required RatesProviderId providerId,
    String? exchangeRateApiKey,
    String? openExchangeRatesAppId,
    bool forceRefresh = false,
  }) async {
    fetchCount++;
    lastForceRefresh = forceRefresh;
    if (error != null) throw error!;
    return next ?? RateSnapshot.dummy();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureMemory;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureMemory = {};
  });

  AppSettings settings() => AppSettings(secureMemory: secureMemory);

  group('ConvertController', () {
    test('init does not fetch; refreshRates sets snapshot and amounts', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      expect(repo.fetchCount, 0);
      await c.refreshRates(force: false);
      expect(repo.fetchCount, 1);
      expect(repo.lastForceRefresh, isFalse);
      expect(c.snapshot?.source, 'dummy');
      expect(c.errorMessage, isNull);
      expect(c.usingFallbackRates, isFalse);
      expect(c.amounts['EUR'], 100);
      expect(c.amounts['USD'], closeTo(113.77, 0.01));
      c.dispose();
    });

    test('init applies disk cache without awaiting network', () async {
      final cached = RateSnapshot(
        base: 'EUR',
        asOf: '2026-07-24',
        fetchedAt: DateTime.utc(2026, 7, 24, 15),
        source: 'Frankfurter',
        attribution: 't',
        disclaimer: 't',
        rates: const {'EUR': 1, 'USD': 1.2, 'GBP': 0.85, 'CHF': 0.93, 'JPY': 160},
      );
      final repo = _FakeRepo(
        cached: cached,
        error: RatesException('Cannot reach server', code: 'network'),
      );
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      expect(repo.fetchCount, 0);
      expect(c.snapshot?.source, 'Frankfurter');
      expect(c.snapshot?.rates['USD'], 1.2);
      expect(c.statusMessage, contains('cached'));
      expect(c.usingFallbackRates, isFalse);
      c.dispose();
    });

    test('refreshRates humanizes RatesException and uses dummy', () async {
      final repo = _FakeRepo(
        error: RatesException('Cannot reach server', code: 'network'),
      );
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      await c.refreshRates(force: false);
      expect(c.errorMessage, 'Cannot reach server');
      expect(c.usingFallbackRates, isTrue);
      expect(c.snapshot?.source, 'dummy');
      expect(c.statusMessage, contains('Offline fallback'));
      c.clearError();
      expect(c.errorMessage, isNull);
      c.dispose();
    });

    test('liveAmount recomputes peers', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      await c.refreshRates();
      c.liveAmount('EUR', '200');
      expect(c.amounts['EUR'], 200);
      expect(c.amounts['USD'], closeTo(227.54, 0.01));
      c.dispose();
    });

    test('commitAmount evaluates expression', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      await c.refreshRates();
      c.commitAmount('EUR', '50+50');
      expect(c.amounts['EUR'], 100);
      c.dispose();
    });

    test('reorderCurrencies moves row and persists order', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final s = settings();
      final c = ConvertController(repository: repo, settings: s);
      await c.init();
      await c.refreshRates();
      final before = List<String>.of(c.currencies);
      expect(before.length, greaterThanOrEqualTo(3));
      final eur = c.amounts['EUR'];
      final usd = c.amounts['USD'];

      // Move first item to index 2 (onReorderItem destination after removal).
      c.reorderCurrencies(0, 2);
      expect(c.currencies[0], before[1]);
      expect(c.currencies[1], before[2]);
      expect(c.currencies[2], before[0]);
      expect(c.amounts['EUR'], eur);
      expect(c.amounts['USD'], usd);

      final persisted = await s.visibleCurrencies();
      expect(persisted, c.currencies);
      c.dispose();
    });

    test('reorderCurrencies no-op when indices unchanged', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      await c.refreshRates();
      final before = List<String>.of(c.currencies);
      c.reorderCurrencies(1, 1);
      expect(c.currencies, before);
      c.dispose();
    });
  });

  group('humanizeError', () {
    test('passes RatesException message', () {
      expect(
        ConvertController.humanizeError(RatesException('Nope')),
        'Nope',
      );
    });
  });
}
