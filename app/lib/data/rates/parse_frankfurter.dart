import 'dart:convert';

/// Parsed Frankfurter v2 `/rates` payload (flat array of quote rows).
class ParsedFrankfurterRates {
  const ParsedFrankfurterRates({
    required this.base,
    required this.asOf,
    required this.rates,
    required this.providerKeys,
  });

  final String base;
  final String asOf;
  final Map<String, double> rates;

  /// Unique provider keys from `expand=providers` (may be empty).
  final Set<String> providerKeys;
}

/// Parse Frankfurter v2 rates JSON (array of `{date,base,quote,rate,...}`).
ParsedFrankfurterRates parseFrankfurterRatesJson(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List || decoded.isEmpty) {
    throw const FormatException('Frankfurter JSON: expected non-empty array');
  }

  final rates = <String, double>{};
  final providerKeys = <String>{};
  String? base;
  String? maxDate;

  for (final item in decoded) {
    if (item is! Map) continue;
    final row = Map<String, dynamic>.from(item);
    final quote = (row['quote'] as String?)?.toUpperCase();
    final rateVal = row['rate'];
    final rate = rateVal is num ? rateVal.toDouble() : double.tryParse('$rateVal');
    if (quote == null || quote.isEmpty || rate == null || rate <= 0) {
      continue;
    }
    rates[quote] = rate;

    final rowBase = (row['base'] as String?)?.toUpperCase();
    if (rowBase != null && rowBase.isNotEmpty) {
      base ??= rowBase;
    }

    final date = row['date'] as String?;
    if (date != null && date.isNotEmpty) {
      if (maxDate == null || date.compareTo(maxDate) > 0) {
        maxDate = date;
      }
    }

    final providers = row['providers'];
    if (providers is List) {
      for (final p in providers) {
        if (p is Map && p['key'] is String) {
          providerKeys.add(p['key'] as String);
        }
      }
    }
  }

  if (rates.isEmpty) {
    throw const FormatException('Frankfurter JSON: no currency rates found');
  }

  final resolvedBase = base ?? 'EUR';
  rates.putIfAbsent(resolvedBase, () => 1.0);

  return ParsedFrankfurterRates(
    base: resolvedBase,
    asOf: maxDate ?? '',
    rates: rates,
    providerKeys: providerKeys,
  );
}
