import 'rate_snapshot.dart';

enum RatesProviderId {
  ecbDirect,
  exchangeRateApi,
  openExchangeRates,
}

extension RatesProviderIdX on RatesProviderId {
  String get label => switch (this) {
        RatesProviderId.ecbDirect => 'ECB (direct, offline cache)',
        RatesProviderId.exchangeRateApi => 'ExchangeRate-API (BYO key)',
        RatesProviderId.openExchangeRates => 'Open Exchange Rates (BYO App ID)',
      };

  bool get isByoKey =>
      this == RatesProviderId.exchangeRateApi ||
      this == RatesProviderId.openExchangeRates;
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

/// Appended to network failures so GrapheneOS users enable App info → Network.
const networkPermissionHint =
    ' If this persists on GrapheneOS/hardened Android, enable Network '
    'permission for fxrows in App info.';
