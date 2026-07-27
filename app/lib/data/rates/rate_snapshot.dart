/// Immutable FX rate snapshot from any provider.
class RateSnapshot {
  const RateSnapshot({
    required this.base,
    required this.asOf,
    required this.fetchedAt,
    required this.source,
    required this.attribution,
    required this.disclaimer,
    required this.rates,
  });

  final String base;
  final String asOf;
  final DateTime fetchedAt;
  final String source;
  final String attribution;
  final String disclaimer;

  /// Units of each currency per 1 [base] (typically EUR for ECB).
  final Map<String, double> rates;

  Iterable<String> get currencies => rates.keys;

  /// Returns a copy with [extra] rates merged in (extra wins on key clash).
  RateSnapshot mergedWith(Map<String, double> extra) {
    if (extra.isEmpty) return this;
    return RateSnapshot(
      base: base,
      asOf: asOf,
      fetchedAt: fetchedAt,
      source: source,
      attribution: attribution,
      disclaimer: disclaimer,
      rates: {...rates, ...extra},
    );
  }

  double rateOf(String code) {
    final v = rates[code];
    if (v == null || v <= 0) {
      throw StateError('Unknown or invalid currency: $code');
    }
    return v;
  }

  /// Convert [amount] from [from] to [to] using cross rates via [base].
  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    if (from == to) return amount;
    final fromRate = rateOf(from);
    final toRate = rateOf(to);
    // amount_in_base = amount / fromRate; result = amount_in_base * toRate
    return amount * toRate / fromRate;
  }

  factory RateSnapshot.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final rates = <String, double>{
      for (final e in rawRates.entries) e.key: (e.value as num).toDouble(),
    };
    return RateSnapshot(
      base: json['base'] as String? ?? 'EUR',
      asOf: json['as_of'] as String? ?? '',
      fetchedAt: DateTime.tryParse(json['fetched_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      source: json['source'] as String? ?? 'unknown',
      attribution: json['attribution'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
      rates: rates,
    );
  }

  /// Dummy snapshot for offline UI development / tests.
  factory RateSnapshot.dummy() {
    return RateSnapshot(
      base: 'EUR',
      asOf: '2026-07-24',
      fetchedAt: DateTime.utc(2026, 7, 24, 16),
      source: 'dummy',
      attribution: 'Dummy rates for local UI.',
      disclaimer: 'Not real market data.',
      rates: const {
        'EUR': 1.0,
        'USD': 1.1377,
        'GBP': 0.8539,
        'CHF': 0.9302,
        'GEL': 3.1,
        'JPY': 167.5,
      },
    );
  }
}
