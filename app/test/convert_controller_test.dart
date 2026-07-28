import 'package:flutter_test/flutter_test.dart';
import 'package:fxrows/data/rates/rate_snapshot.dart';
import 'package:fxrows/data/rates/rates_provider.dart';
import 'package:fxrows/data/rates/rates_repository.dart';
import 'package:fxrows/features/convert/convert_controller.dart';
import 'package:fxrows/features/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends RatesRepository {
  _FakeRepo({this.next, this.error});

  RateSnapshot? next;
  Object? error;
  int fetchCount = 0;

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

  bool? lastForceRefresh;
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
    test('refreshRates sets snapshot and amounts', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      expect(repo.fetchCount, 1);
      expect(c.snapshot?.source, 'dummy');
      expect(c.errorMessage, isNull);
      expect(c.usingFallbackRates, isFalse);
      expect(c.amounts['EUR'], 100);
      expect(c.amounts['USD'], closeTo(113.77, 0.01));
      c.dispose();
    });

    test('refreshRates humanizes RatesException and uses dummy', () async {
      final repo = _FakeRepo(
        error: RatesException('Cannot reach server', code: 'network'),
      );
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
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
      c.liveAmount('EUR', '200');
      expect(c.amounts['EUR'], 200);
      expect(c.amounts['USD'], closeTo(227.54, 0.01));
      c.dispose();
    });

    test('commitAmount evaluates expression', () async {
      final repo = _FakeRepo(next: RateSnapshot.dummy());
      final c = ConvertController(repository: repo, settings: settings());
      await c.init();
      c.commitAmount('EUR', '50+50');
      expect(c.amounts['EUR'], 100);
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
