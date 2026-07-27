import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/rates/rates_provider.dart';

class AppSettings {
  AppSettings({
    SharedPreferences? prefs,
    FlutterSecureStorage? secure,
  })  : _prefs = prefs,
        _secure = secure ?? const FlutterSecureStorage();

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secure;

  static const _kProvider = 'provider_id';
  static const _kAggUrl = 'agg_base_url';
  static const _kCurrencies = 'visible_currencies';
  static const _kApiKey = 'exchangerate_api_key';

  static const defaultCurrencies = ['EUR', 'USD', 'GBP', 'GEL', 'CHF'];

  /// Production aggregator. Override at build time with
  /// `--dart-define=FXBOARD_AGG_URL=…`, or in Settings for local/self-host.
  static const defaultAggUrl = String.fromEnvironment(
    'FXBOARD_AGG_URL',
    defaultValue: 'https://fxboard.wynpakt.com',
  );

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<RatesProviderId> providerId() async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_kProvider);
    return RatesProviderId.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => RatesProviderId.aggServer,
    );
  }

  Future<void> setProviderId(RatesProviderId id) async {
    await _ensurePrefs();
    await _prefs!.setString(_kProvider, id.name);
  }

  Future<String> aggBaseUrl() async {
    await _ensurePrefs();
    return _prefs!.getString(_kAggUrl) ?? defaultAggUrl;
  }

  Future<void> setAggBaseUrl(String url) async {
    await _ensurePrefs();
    await _prefs!.setString(_kAggUrl, url.trim());
  }

  Future<List<String>> visibleCurrencies() async {
    await _ensurePrefs();
    return _prefs!.getStringList(_kCurrencies) ?? List.of(defaultCurrencies);
  }

  Future<void> setVisibleCurrencies(List<String> codes) async {
    await _ensurePrefs();
    await _prefs!.setStringList(
      _kCurrencies,
      codes.map((c) => c.toUpperCase()).toList(),
    );
  }

  Future<String?> exchangeRateApiKey() => _secure.read(key: _kApiKey);

  Future<void> setExchangeRateApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _secure.delete(key: _kApiKey);
    } else {
      await _secure.write(key: _kApiKey, value: key.trim());
    }
  }
}
