import 'package:http/http.dart' as http;

import 'frankfurter_constants.dart';
import 'parse_frankfurter.dart';
import 'rate_snapshot.dart';
import 'rates_provider.dart';

/// Default provider: Frankfurter v2 blended central-bank rates (no API key).
class FrankfurterProvider implements RatesProvider {
  FrankfurterProvider({
    http.Client? client,
    this.url = frankfurterRatesUrl,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String url;

  @override
  RatesProviderId get id => RatesProviderId.frankfurter;

  @override
  Future<RateSnapshot> fetchLatest() async {
    late final http.Response res;
    try {
      res = await _client
          .get(
            Uri.parse(url),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw RatesException(
        'Cannot reach Frankfurter rate API.$networkPermissionHint',
        code: 'network',
      );
    }
    if (res.statusCode != 200) {
      throw RatesException(
        'Frankfurter API error HTTP ${res.statusCode}',
        code: 'http_${res.statusCode}',
      );
    }

    try {
      final parsed = parseFrankfurterRatesJson(res.body);
      var attribution = frankfurterAttribution;
      if (parsed.providerKeys.isNotEmpty) {
        attribution =
            '$attribution This snapshot blends data from '
            '${parsed.providerKeys.length} providers.';
      }
      return RateSnapshot(
        base: parsed.base,
        asOf: parsed.asOf,
        fetchedAt: DateTime.now().toUtc(),
        source: 'Frankfurter',
        attribution: attribution,
        disclaimer: frankfurterDisclaimer,
        rates: parsed.rates,
      );
    } on FormatException catch (e) {
      throw RatesException(e.message, code: 'parse');
    }
  }
}
