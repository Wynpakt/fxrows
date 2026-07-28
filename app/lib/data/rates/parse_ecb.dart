/// Parse ECB eurofxref-daily.xml into as-of date and rates.
/// Rates are EUR → currency (units of foreign currency per 1 EUR). EUR is always 1.
({String asOf, Map<String, double> rates}) parseEcbDailyXml(String xml) {
  final timeMatch = RegExp(r'''time=["'](\d{4}-\d{2}-\d{2})["']''').firstMatch(xml);
  if (timeMatch == null) {
    throw FormatException('ECB XML: missing Cube time attribute');
  }

  final rates = <String, double>{'EUR': 1};
  final cubeRe = RegExp(
    r'''currency=["']([A-Z]{3})["']\s+rate=["']([0-9.]+)["']''',
  );
  for (final m in cubeRe.allMatches(xml)) {
    final code = m.group(1)!;
    final rate = double.tryParse(m.group(2)!);
    if (rate == null || !rate.isFinite || rate <= 0) {
      throw FormatException('ECB XML: invalid rate for $code');
    }
    rates[code] = rate;
  }

  if (rates.length < 2) {
    throw FormatException('ECB XML: no currency rates found');
  }

  return (asOf: timeMatch.group(1)!, rates: rates);
}
