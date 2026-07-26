import 'dart:convert';

import 'package:http/http.dart' as http;

import 'rate_snapshot.dart';
import 'rates_provider.dart';

/// Default provider: thin aggregation server redistributing ECB reference rates.
class AggServerProvider implements RatesProvider {
  AggServerProvider({
    http.Client? client,
    String baseUrl = 'http://127.0.0.1:8787',
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String baseUrl;

  @override
  RatesProviderId get id => RatesProviderId.aggServer;

  @override
  Future<RateSnapshot> fetchLatest() async {
    final uri = Uri.parse('$baseUrl/v1/latest');
    late final http.Response res;
    try {
      res = await _client.get(uri).timeout(const Duration(seconds: 5));
    } catch (e) {
      throw RatesException(
        'Cannot reach fxboard server at $baseUrl. Is it running?',
        code: 'network',
      );
    }
    if (res.statusCode != 200) {
      throw RatesException(
        'Server error HTTP ${res.statusCode}',
        code: 'http_${res.statusCode}',
      );
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return RateSnapshot.fromJson(json);
  }
}
