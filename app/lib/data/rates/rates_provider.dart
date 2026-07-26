import 'rate_snapshot.dart';

enum RatesProviderId {
  aggServer,
  exchangeRateApi,
}

extension RatesProviderIdX on RatesProviderId {
  String get label => switch (this) {
        RatesProviderId.aggServer => 'fxboard server (ECB)',
        RatesProviderId.exchangeRateApi => 'ExchangeRate-API (BYO key)',
      };
}

abstract class RatesProvider {
  RatesProviderId get id;

  Future<RateSnapshot> fetchLatest();
}

class RatesException implements Exception {
  RatesException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
