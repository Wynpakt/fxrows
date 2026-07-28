import 'package:flutter/foundation.dart';

import '../../data/rates/rate_snapshot.dart';
import '../../data/rates/rates_provider.dart';
import '../../data/rates/rates_repository.dart';
import '../settings/app_settings.dart';
import 'expression.dart';

class ConvertController extends ChangeNotifier {
  ConvertController({
    RatesRepository? repository,
    AppSettings? settings,
  })  : _repository = repository ?? RatesRepository(),
        _settings = settings ?? AppSettings();

  final RatesRepository _repository;
  final AppSettings _settings;

  RateSnapshot? snapshot;
  Map<String, double> customRates = {};
  List<String> currencies = List.of(AppSettings.defaultCurrencies);
  final Map<String, double> amounts = {};
  String? editingCode;
  String? statusMessage;
  String? errorMessage;
  bool loading = false;
  /// True when showing [RateSnapshot.dummy] after a failed fetch with no cache.
  bool usingFallbackRates = false;
  RatesProviderId providerId = RatesProviderId.ecbDirect;

  bool isCustom(String code) => customRates.containsKey(code.toUpperCase());

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  static String humanizeError(Object e) {
    if (e is RatesException) return e.message;
    final s = e.toString();
    if (s.startsWith('Exception: ')) return s.substring(11);
    if (s.startsWith('ArgumentError: ')) return s.substring(15);
    return 'Something went wrong. Try again.';
  }

  Future<void> init() async {
    currencies = await _settings.visibleCurrencies();
    providerId = await _settings.providerId();
    customRates = await _settings.customRates();
    for (final c in currencies) {
      amounts.putIfAbsent(c, () => c == currencies.first ? 100 : 0);
    }

    // Offline-first: paint from disk cache before any network call.
    final cached = await _repository.loadCached(providerId);
    if (cached != null) {
      _applySnapshot(cached, fromNetwork: false);
      notifyListeners();
    }

    await refreshRates(force: false);
  }

  /// [force] true = manual refresh (bypass smart/throttle policy).
  Future<void> refreshRates({bool force = true}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      providerId = await _settings.providerId();
      customRates = await _settings.customRates();
      final eraKey = await _settings.exchangeRateApiKey();
      final oerId = await _settings.openExchangeRatesAppId();
      final next = await _repository.fetch(
        providerId: providerId,
        exchangeRateApiKey: eraKey,
        openExchangeRatesAppId: oerId,
        forceRefresh: force,
      );
      _applySnapshot(next, fromNetwork: true);
    } catch (e) {
      errorMessage = humanizeError(e);
      // Keep UI usable with last snapshot or dummy + customs.
      customRates = await _settings.customRates();
      snapshot ??= RateSnapshot.dummy().mergedWith(customRates);
      usingFallbackRates = snapshot!.source == 'dummy';
      if (usingFallbackRates) {
        statusMessage =
            'Offline fallback rates (not live). Retry when you are online.';
      } else if (snapshot != null) {
        statusMessage =
            '${snapshot!.source} · as of ${snapshot!.asOf} · cached '
            '(refresh failed)';
      }
      if (amounts.values.every((v) => v == 0) && currencies.isNotEmpty) {
        _recomputeFrom(currencies.first, 100);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applySnapshot(RateSnapshot next, {required bool fromNetwork}) {
    final merged = next.mergedWith(customRates);
    snapshot = merged;
    currencies = [
      for (final c in currencies)
        if (merged.rates.containsKey(c)) c,
    ];
    if (currencies.isEmpty) {
      currencies = [
        for (final c in AppSettings.defaultCurrencies)
          if (merged.rates.containsKey(c)) c,
      ];
      if (currencies.isEmpty) {
        currencies = merged.rates.keys.take(5).toList();
      }
    }
    final pivot = currencies.first;
    final pivotAmount = amounts[pivot] ?? 100;
    _recomputeFrom(pivot, pivotAmount);
    usingFallbackRates = false;
    final customNote =
        customRates.isEmpty ? '' : ' · ${customRates.length} custom';
    final cacheNote = fromNetwork ? '' : ' · cached';
    statusMessage =
        '${next.source} · as of ${next.asOf} · ${merged.rates.length} '
        'currencies$customNote$cacheNote';
  }

  void addCurrency(String code) {
    final c = code.toUpperCase();
    final snap = snapshot;
    if (snap == null || !snap.rates.containsKey(c)) return;
    if (currencies.contains(c)) return;
    currencies = [...currencies, c];
    final pivot = currencies.first;
    amounts[c] = snap.convert(
      amount: amounts[pivot] ?? 0,
      from: pivot,
      to: c,
    );
    _settings.setVisibleCurrencies(currencies);
    notifyListeners();
  }

  /// Persist a manual rate (units of [code] per 1 snapshot base) and show it.
  Future<void> addCustomCurrency(String code, double ratePerBase) async {
    final c = code.toUpperCase().trim();
    if (!RegExp(r'^[A-Z]{3,8}$').hasMatch(c)) {
      throw ArgumentError('Currency code must be 3-8 letters');
    }
    if (ratePerBase <= 0) {
      throw ArgumentError('Rate must be positive');
    }
    await _settings.upsertCustomRate(c, ratePerBase);
    customRates = await _settings.customRates();
    final base = snapshot;
    if (base != null) {
      snapshot = RateSnapshot(
        base: base.base,
        asOf: base.asOf,
        fetchedAt: base.fetchedAt,
        source: base.source,
        attribution: base.attribution,
        disclaimer: base.disclaimer,
        rates: {...base.rates, ...customRates},
      );
    } else {
      snapshot = RateSnapshot.dummy().mergedWith(customRates);
    }
    if (!currencies.contains(c)) {
      currencies = [...currencies, c];
      final snap = snapshot!;
      final pivot = currencies.first;
      amounts[c] = snap.convert(
        amount: amounts[pivot] ?? 0,
        from: pivot,
        to: c,
      );
      await _settings.setVisibleCurrencies(currencies);
    } else {
      final pivot = currencies.first;
      _recomputeFrom(pivot, amounts[pivot] ?? 0);
    }
    notifyListeners();
  }

  Future<void> updateCustomRate(String code, double ratePerBase) async {
    await addCustomCurrency(code, ratePerBase);
  }

  Future<void> deleteCustomCurrency(String code) async {
    final c = code.toUpperCase();
    await _settings.removeCustomRate(c);
    customRates = await _settings.customRates();
    if (currencies.contains(c) && currencies.length > 2) {
      currencies = [for (final x in currencies) if (x != c) x];
      amounts.remove(c);
      await _settings.setVisibleCurrencies(currencies);
    }
    await refreshRates(force: false);
  }

  void removeCurrency(String code) {
    if (currencies.length <= 2) return;
    currencies = [for (final c in currencies) if (c != code) c];
    amounts.remove(code);
    _settings.setVisibleCurrencies(currencies);
    notifyListeners();
  }

  void setEditing(String? code) {
    editingCode = code;
    notifyListeners();
  }

  /// Apply raw field text for [code]: evaluate expression if needed, then sync.
  void commitAmount(String code, String raw) {
    final value = tryEvaluateExpression(raw);
    if (value == null) {
      notifyListeners();
      return;
    }
    _recomputeFrom(code, value);
    notifyListeners();
  }

  /// Live sync while typing a plain number (no expression yet).
  void liveAmount(String code, String raw) {
    if (RegExp(r'[+\-*/()]').hasMatch(raw.replaceFirst(RegExp(r'^[+-]'), ''))) {
      return; // wait for commit when expression
    }
    final value = tryEvaluateExpression(raw);
    if (value == null) return;
    _recomputeFrom(code, value);
    notifyListeners();
  }

  void _recomputeFrom(String source, double amount) {
    final snap = snapshot;
    if (snap == null) return;
    amounts[source] = amount;
    for (final c in currencies) {
      if (c == source) continue;
      if (!snap.rates.containsKey(c)) continue;
      amounts[c] = snap.convert(amount: amount, from: source, to: c);
    }
  }

  String formatAmount(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) {
      return v.toStringAsFixed(v.abs() >= 1000 ? 0 : 2);
    }
    if (v.abs() >= 1000) return v.toStringAsFixed(2);
    if (v.abs() >= 1) return v.toStringAsFixed(2);
    return v.toStringAsFixed(4);
  }
}
