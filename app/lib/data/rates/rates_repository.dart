import 'package:http/http.dart' as http;

import 'ecb_direct_provider.dart';
import 'ecb_refresh_policy.dart';
import 'exchangerate_api_provider.dart';
import 'frankfurter_provider.dart';
import 'open_exchange_rates_provider.dart';
import 'rate_snapshot.dart';
import 'rate_snapshot_cache.dart';
import 'rates_provider.dart';

class RatesRepository {
  RatesRepository({
    http.Client? client,
    RateSnapshotCache? cache,
    DateTime Function()? clock,
  })  : _client = client,
        _cache = cache ?? RateSnapshotCache(),
        _clock = clock ?? DateTime.now;

  final http.Client? _client;
  final RateSnapshotCache _cache;
  final DateTime Function() _clock;

  Future<RateSnapshot?> loadCached(RatesProviderId providerId) =>
      _cache.load(providerId);

  /// Returns a snapshot, using the local cache when a network refresh is
  /// unnecessary. [forceRefresh] bypasses the smart/throttled policy (manual).
  Future<RateSnapshot> fetch({
    required RatesProviderId providerId,
    String? exchangeRateApiKey,
    String? openExchangeRatesAppId,
    bool forceRefresh = false,
  }) async {
    final cached = await _cache.load(providerId);
    final now = _clock().toUtc();
    final needsNetwork = switch (providerId) {
      RatesProviderId.frankfurter => shouldRefreshDailyRates(
          cached: cached,
          nowUtc: now,
          force: forceRefresh,
        ),
      RatesProviderId.ecbDirect => shouldRefreshEcb(
          cached: cached,
          nowUtc: now,
          force: forceRefresh,
        ),
      RatesProviderId.exchangeRateApi ||
      RatesProviderId.openExchangeRates =>
        shouldRefreshThrottled(
          cached: cached,
          nowUtc: now,
          force: forceRefresh,
        ),
    };

    if (!needsNetwork && cached != null) {
      return cached;
    }

    final owned = _client == null;
    final client = _client ?? http.Client();
    try {
      final provider = switch (providerId) {
        RatesProviderId.frankfurter => FrankfurterProvider(client: client),
        RatesProviderId.ecbDirect => EcbDirectProvider(client: client),
        RatesProviderId.exchangeRateApi => ExchangeRateApiProvider(
            apiKey: exchangeRateApiKey ?? '',
            client: client,
          ),
        RatesProviderId.openExchangeRates => OpenExchangeRatesProvider(
            appId: openExchangeRatesAppId ?? '',
            client: client,
          ),
      };
      final next = await provider.fetchLatest();
      await _cache.save(providerId, next);
      return next;
    } catch (_) {
      // Auto-refresh: keep serving disk cache. Manual force: surface the error.
      if (!forceRefresh && cached != null) return cached;
      rethrow;
    } finally {
      if (owned) client.close();
    }
  }
}
