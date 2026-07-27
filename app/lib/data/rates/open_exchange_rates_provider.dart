import 'dart:convert';

import 'package:http/http.dart' as http;

import 'rate_snapshot.dart';
import 'rates_provider.dart';

/// BYO App-ID provider. Requests go from the device to Open Exchange Rates only.
///
/// Free plans use USD as base; [RateSnapshot.convert] still cross-rates correctly.
class OpenExchangeRatesProvider implements RatesProvider {
  OpenExchangeRatesProvider({
    required this.appId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String appId;
  final http.Client _client;

  @override
  RatesProviderId get id => RatesProviderId.openExchangeRates;

  @override
  Future<RateSnapshot> fetchLatest() async {
    if (appId.trim().isEmpty) {
      throw RatesException('Open Exchange Rates App ID required', code: 'missing_key');
    }
    final uri = Uri.https('openexchangerates.org', '/api/latest.json', {
      'app_id': appId.trim(),
    });
    late final http.Response res;
    try {
      res = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw RatesException(
        'Network error contacting Open Exchange Rates.$networkPermissionHint',
        code: 'network',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || json['error'] == true) {
      throw RatesException(
        _errorMessage(json, res.statusCode),
        code: 'oer_${res.statusCode}',
      );
    }

    return parseOpenExchangeRatesLatest(json);
  }

  static String _errorMessage(Map<String, dynamic> json, int status) {
    final message = json['message'] as String?;
    final description = json['description'] as String?;
    return switch (message) {
      'invalid_app_id' || 'missing_app_id' => 'Invalid or missing App ID',
      'not_allowed' => description ?? 'Request not allowed for this plan',
      'access_restricted' => description ?? 'Access restricted (quota or plan)',
      _ => description ?? message ?? 'Open Exchange Rates HTTP $status',
    };
  }
}

/// Maps an OER `/latest.json` body to [RateSnapshot] (no network).
RateSnapshot parseOpenExchangeRatesLatest(Map<String, dynamic> json) {
  final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
  final rates = <String, double>{
    for (final e in rawRates.entries) e.key: (e.value as num).toDouble(),
  };
  final base = (json['base'] as String? ?? 'USD').toUpperCase();
  rates.putIfAbsent(base, () => 1.0);

  final ts = json['timestamp'] as int?;
  final asOf = ts != null
      ? DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true)
          .toIso8601String()
          .substring(0, 10)
      : '';

  return RateSnapshot(
    base: base,
    asOf: asOf,
    fetchedAt: DateTime.now().toUtc(),
    source: 'Open Exchange Rates',
    attribution:
        'Rates from Open Exchange Rates (your App ID). See their terms of use.',
    disclaimer: json['disclaimer'] as String? ??
        'Informational only. Not for transaction settlement. Subject to provider terms.',
    rates: rates,
  );
}
