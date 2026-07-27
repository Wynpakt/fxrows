import 'dart:convert';

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
  static const _kCustomRates = 'custom_rates';

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

  /// Manual rates as units of currency per 1 provider base (typically EUR).
  Future<Map<String, double>> customRates() async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_kCustomRates);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in decoded.entries)
          e.key.toUpperCase(): (e.value as num).toDouble(),
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> setCustomRates(Map<String, double> rates) async {
    await _ensurePrefs();
    final normalized = <String, double>{
      for (final e in rates.entries)
        if (e.value > 0) e.key.toUpperCase(): e.value,
    };
    if (normalized.isEmpty) {
      await _prefs!.remove(_kCustomRates);
    } else {
      await _prefs!.setString(_kCustomRates, jsonEncode(normalized));
    }
  }

  Future<void> upsertCustomRate(String code, double ratePerBase) async {
    final next = Map<String, double>.from(await customRates());
    next[code.toUpperCase()] = ratePerBase;
    await setCustomRates(next);
  }

  Future<void> removeCustomRate(String code) async {
    final next = Map<String, double>.from(await customRates());
    next.remove(code.toUpperCase());
    await setCustomRates(next);
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
