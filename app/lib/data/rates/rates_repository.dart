import 'package:http/http.dart' as http;

import 'agg_server_provider.dart';
import 'exchangerate_api_provider.dart';
import 'open_exchange_rates_provider.dart';
import 'rate_snapshot.dart';
import 'rates_provider.dart';

class RatesRepository {
  RatesRepository({
    this.aggBaseUrl = const String.fromEnvironment(
      'FXROWS_AGG_URL',
      defaultValue: 'https://fxrows.wynpakt.com',
    ),
    http.Client? client,
  }) : _client = client;

  String aggBaseUrl;
  final http.Client? _client;

  Future<RateSnapshot> fetch({
    required RatesProviderId providerId,
    String? exchangeRateApiKey,
    String? openExchangeRatesAppId,
  }) async {
    final owned = _client == null;
    final client = _client ?? http.Client();
    try {
      final provider = switch (providerId) {
        RatesProviderId.aggServer => AggServerProvider(
            baseUrl: aggBaseUrl,
            client: client,
          ),
        RatesProviderId.exchangeRateApi => ExchangeRateApiProvider(
            apiKey: exchangeRateApiKey ?? '',
            client: client,
          ),
        RatesProviderId.openExchangeRates => OpenExchangeRatesProvider(
            appId: openExchangeRatesAppId ?? '',
            client: client,
          ),
      };
      return await provider.fetchLatest();
    } finally {
      if (owned) client.close();
    }
  }
}
