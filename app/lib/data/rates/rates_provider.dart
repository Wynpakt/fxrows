import 'rate_snapshot.dart';

enum RatesProviderId {
  /// Default: Frankfurter v2 (central-bank aggregation, no key).
  frankfurter,
  /// Advanced: unmodified ECB eurofxref XML.
  ecbDirect,
  exchangeRateApi,
  openExchangeRates,
}

extension RatesProviderIdX on RatesProviderId {
  String get label => switch (this) {
        RatesProviderId.frankfurter => 'Frankfurter (central banks)',
        RatesProviderId.ecbDirect => 'ECB (direct, offline cache)',
        RatesProviderId.exchangeRateApi => 'ExchangeRate-API (BYO key)',
        RatesProviderId.openExchangeRates => 'Open Exchange Rates (BYO App ID)',
      };

  /// Shown under Settings → Advanced (not the primary default).
  bool get isAdvanced =>
      this == RatesProviderId.ecbDirect ||
      this == RatesProviderId.exchangeRateApi ||
      this == RatesProviderId.openExchangeRates;

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
