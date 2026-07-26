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
  List<String> currencies = List.of(AppSettings.defaultCurrencies);
  final Map<String, double> amounts = {};
  String? editingCode;
  String? statusMessage;
  String? errorMessage;
  bool loading = false;
  RatesProviderId providerId = RatesProviderId.aggServer;

  Future<void> init() async {
    currencies = await _settings.visibleCurrencies();
    providerId = await _settings.providerId();
    _repository.aggBaseUrl = await _settings.aggBaseUrl();
    for (final c in currencies) {
      amounts.putIfAbsent(c, () => c == currencies.first ? 100 : 0);
    }
    await refreshRates();
  }

  Future<void> refreshRates() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      providerId = await _settings.providerId();
      _repository.aggBaseUrl = await _settings.aggBaseUrl();
      final key = await _settings.exchangeRateApiKey();
      final next = await _repository.fetch(
        providerId: providerId,
        exchangeRateApiKey: key,
      );
      snapshot = next;
      // Drop currencies the provider does not know; keep order for known ones.
      currencies = [
        for (final c in currencies)
          if (next.rates.containsKey(c)) c,
      ];
      if (currencies.isEmpty) {
        currencies = [
          for (final c in AppSettings.defaultCurrencies)
            if (next.rates.containsKey(c)) c,
        ];
        if (currencies.isEmpty) {
          currencies = next.rates.keys.take(5).toList();
        }
      }
      final pivot = currencies.first;
      final pivotAmount = amounts[pivot] ?? 100;
      _recomputeFrom(pivot, pivotAmount);
      statusMessage =
          '${next.source} · as of ${next.asOf} · ${next.rates.length} currencies';
    } catch (e) {
      errorMessage = e.toString();
      // Keep UI usable with last snapshot or dummy.
      snapshot ??= RateSnapshot.dummy();
      if (amounts.values.every((v) => v == 0)) {
        _recomputeFrom(currencies.first, 100);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
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
