import 'package:http/http.dart' as http;

import 'ecb_constants.dart';
import 'parse_ecb.dart';
import 'rate_snapshot.dart';
import 'rates_provider.dart';

/// Advanced provider: fetch ECB eurofxref-daily.xml directly from the device.
class EcbDirectProvider implements RatesProvider {
  EcbDirectProvider({
    http.Client? client,
    this.url = ecbDailyUrl,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String url;

  @override
  RatesProviderId get id => RatesProviderId.ecbDirect;

  @override
  Future<RateSnapshot> fetchLatest() async {
    late final http.Response res;
    try {
      res = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw RatesException(
        'Cannot reach ECB rate feed.$networkPermissionHint',
        code: 'network',
      );
    }
    if (res.statusCode != 200) {
      throw RatesException(
        'ECB feed error HTTP ${res.statusCode}',
        code: 'http_${res.statusCode}',
      );
    }

    try {
      final parsed = parseEcbDailyXml(res.body);
      return RateSnapshot(
        base: 'EUR',
        asOf: parsed.asOf,
        fetchedAt: DateTime.now().toUtc(),
        source: 'ECB',
        attribution: ecbAttribution,
        disclaimer: ecbDisclaimer,
        rates: parsed.rates,
      );
    } on FormatException catch (e) {
      throw RatesException(e.message, code: 'parse');
    }
  }
}
