import 'dart:convert';

import 'package:http/http.dart' as http;

import 'rate_snapshot.dart';
import 'rates_provider.dart';

/// BYO-key provider. Requests go from the device to ExchangeRate-API only.
class ExchangeRateApiProvider implements RatesProvider {
  ExchangeRateApiProvider({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  @override
  RatesProviderId get id => RatesProviderId.exchangeRateApi;

  @override
  Future<RateSnapshot> fetchLatest() async {
    if (apiKey.trim().isEmpty) {
      throw RatesException('API key required', code: 'missing_key');
    }
    final uri = Uri.parse(
      'https://v6.exchangerate-api.com/v6/${Uri.encodeComponent(apiKey.trim())}/latest/EUR',
    );
    late final http.Response res;
    try {
      res = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw RatesException('Network error contacting ExchangeRate-API', code: 'network');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final result = json['result'] as String?;
    if (result != 'success') {
      final err = json['error-type'] as String? ?? 'unknown';
      final message = switch (err) {
        'invalid-key' => 'Invalid API key',
        'inactive-account' => 'Account inactive — confirm your email',
        'quota-reached' => 'Monthly quota reached',
        _ => 'ExchangeRate-API error: $err',
      };
      throw RatesException(message, code: err);
    }

    final rawRates = json['conversion_rates'] as Map<String, dynamic>? ?? {};
    final rates = <String, double>{
      for (final e in rawRates.entries) e.key: (e.value as num).toDouble(),
    };

    final lastUnix = json['time_last_update_unix'] as int?;
    final asOf = lastUnix != null
        ? DateTime.fromMillisecondsSinceEpoch(lastUnix * 1000, isUtc: true)
            .toIso8601String()
            .substring(0, 10)
        : (json['time_last_update_utc'] as String? ?? '').split(' ').first;

    return RateSnapshot(
      base: json['base_code'] as String? ?? 'EUR',
      asOf: asOf,
      fetchedAt: DateTime.now().toUtc(),
      source: 'ExchangeRate-API',
      attribution:
          'Rates from ExchangeRate-API (your API key). See their terms of use.',
      disclaimer:
          'Informational only. Not for transaction settlement. Subject to provider terms.',
      rates: rates,
    );
  }
}
