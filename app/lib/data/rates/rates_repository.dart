import 'agg_server_provider.dart';
import 'exchangerate_api_provider.dart';
import 'rate_snapshot.dart';
import 'rates_provider.dart';

class RatesRepository {
  RatesRepository({
    this.aggBaseUrl = 'http://127.0.0.1:8787',
  });

  String aggBaseUrl;

  Future<RateSnapshot> fetch({
    required RatesProviderId providerId,
    String? exchangeRateApiKey,
  }) {
    final provider = switch (providerId) {
      RatesProviderId.aggServer => AggServerProvider(baseUrl: aggBaseUrl),
      RatesProviderId.exchangeRateApi => ExchangeRateApiProvider(
          apiKey: exchangeRateApiKey ?? '',
        ),
    };
    return provider.fetchLatest();
  }
}
