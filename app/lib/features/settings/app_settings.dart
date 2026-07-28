import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/rates/rates_provider.dart';

class AppSettings {
  AppSettings({
    SharedPreferences? prefs,
    FlutterSecureStorage? secure,
    Map<String, String>? secureMemory,
  })  : _prefs = prefs,
        _secure = secure ?? const FlutterSecureStorage(),
        _secureMemory = secureMemory;

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secure;
  /// When non-null (tests), keys are stored here instead of platform secure storage.
  final Map<String, String>? _secureMemory;

  static const _kProvider = 'provider_id';
  static const _kCurrencies = 'visible_currencies';
  static const _kApiKey = 'exchangerate_api_key';
  static const _kOerAppId = 'open_exchange_rates_app_id';
  static const _kCustomRates = 'custom_rates';

  static const defaultCurrencies = ['EUR', 'USD', 'GBP', 'GEL', 'CHF'];

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<RatesProviderId> providerId() async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_kProvider);
    if (raw == null || raw.isEmpty || raw == 'aggServer') {
      // Legacy aggregator preference → ECB direct (no wynpakt server).
      if (raw == 'aggServer') {
        await _prefs!.setString(_kProvider, RatesProviderId.ecbDirect.name);
      }
      return RatesProviderId.ecbDirect;
    }
    return RatesProviderId.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => RatesProviderId.ecbDirect,
    );
  }

  Future<void> setProviderId(RatesProviderId id) async {
    await _ensurePrefs();
    await _prefs!.setString(_kProvider, id.name);
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

  Future<String?> exchangeRateApiKey() async {
    if (_secureMemory != null) return _secureMemory[_kApiKey];
    return _secure.read(key: _kApiKey);
  }

  Future<void> setExchangeRateApiKey(String? key) async {
    if (_secureMemory != null) {
      if (key == null || key.trim().isEmpty) {
        _secureMemory.remove(_kApiKey);
      } else {
        _secureMemory[_kApiKey] = key.trim();
      }
      return;
    }
    if (key == null || key.trim().isEmpty) {
      await _secure.delete(key: _kApiKey);
    } else {
      await _secure.write(key: _kApiKey, value: key.trim());
    }
  }

  Future<String?> openExchangeRatesAppId() async {
    if (_secureMemory != null) return _secureMemory[_kOerAppId];
    return _secure.read(key: _kOerAppId);
  }

  Future<void> setOpenExchangeRatesAppId(String? appId) async {
    if (_secureMemory != null) {
      if (appId == null || appId.trim().isEmpty) {
        _secureMemory.remove(_kOerAppId);
      } else {
        _secureMemory[_kOerAppId] = appId.trim();
      }
      return;
    }
    if (appId == null || appId.trim().isEmpty) {
      await _secure.delete(key: _kOerAppId);
    } else {
      await _secure.write(key: _kOerAppId, value: appId.trim());
    }
  }
}
