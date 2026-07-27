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
  });

  String aggBaseUrl;

  Future<RateSnapshot> fetch({
    required RatesProviderId providerId,
    String? exchangeRateApiKey,
    String? openExchangeRatesAppId,
  }) {
    final provider = switch (providerId) {
      RatesProviderId.aggServer => AggServerProvider(baseUrl: aggBaseUrl),
      RatesProviderId.exchangeRateApi => ExchangeRateApiProvider(
          apiKey: exchangeRateApiKey ?? '',
        ),
      RatesProviderId.openExchangeRates => OpenExchangeRatesProvider(
          appId: openExchangeRatesAppId ?? '',
        ),
    };
    return provider.fetchLatest();
  }
}
