import 'rate_snapshot.dart';

/// Approximate Europe/Berlin offset (CET/CEST) without a timezone database.
/// DST: last Sunday of March 01:00 UTC → last Sunday of October 01:00 UTC.
Duration centralEuropeanOffset(DateTime utc) {
  final u = utc.toUtc();
  final year = u.year;
  final dstStart = _lastSundayOfMonth(year, 3).add(const Duration(hours: 1));
  final dstEnd = _lastSundayOfMonth(year, 10).add(const Duration(hours: 1));
  final inDst = !u.isBefore(dstStart) && u.isBefore(dstEnd);
  return Duration(hours: inDst ? 2 : 1);
}

DateTime toCentralEuropean(DateTime utc) =>
    utc.toUtc().add(centralEuropeanOffset(utc));

DateTime _lastSundayOfMonth(int year, int month) {
  final firstNext = month == 12
      ? DateTime.utc(year + 1, 1, 1)
      : DateTime.utc(year, month + 1, 1);
  var d = firstNext.subtract(const Duration(days: 1));
  while (d.weekday != DateTime.sunday) {
    d = d.subtract(const Duration(days: 1));
  }
  return DateTime.utc(d.year, d.month, d.day);
}

/// Previous Mon–Fri calendar day (ignores ECB TARGET holidays).
DateTime previousBusinessDay(DateTime date) {
  var d = DateTime(date.year, date.month, date.day)
      .subtract(const Duration(days: 1));
  while (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
    d = d.subtract(const Duration(days: 1));
  }
  return d;
}

/// Expected ECB `as_of` date for [nowCet] (local civil date in CET/CEST).
///
/// ECB typically publishes ~16:00 CET on TARGET business days. Before ~16:15
/// on a weekday, today's file may not exist yet — expect the previous
/// business day. Weekends resolve to Friday.
DateTime expectedEcbAsOfDate(DateTime nowCet) {
  var d = DateTime(nowCet.year, nowCet.month, nowCet.day);
  final afterPublish =
      nowCet.hour > 16 || (nowCet.hour == 16 && nowCet.minute >= 15);

  if (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
    return previousBusinessDay(d);
  }
  if (!afterPublish) {
    return previousBusinessDay(d);
  }
  return d;
}

/// Whether the ECB cache should be refreshed from the network.
bool shouldRefreshEcb({
  required RateSnapshot? cached,
  required DateTime nowUtc,
  bool force = false,
}) {
  if (force) return true;
  if (cached == null || cached.asOf.isEmpty) return true;

  final asOf = DateTime.tryParse(cached.asOf);
  if (asOf == null) return true;

  final nowCet = toCentralEuropean(nowUtc);
  final expected = expectedEcbAsOfDate(nowCet);
  final asOfDate = DateTime(asOf.year, asOf.month, asOf.day);
  final expectedDate = DateTime(expected.year, expected.month, expected.day);

  if (asOfDate.isBefore(expectedDate)) return true;

  // Safety: if as_of looks current but we last fetched a long time ago on a
  // weekday after the publish window, try again (e.g. midday publish slip).
  final age = nowUtc.toUtc().difference(cached.fetchedAt.toUtc());
  if (age > const Duration(hours: 20) &&
      nowCet.weekday >= DateTime.monday &&
      nowCet.weekday <= DateTime.friday) {
    final afterPublish =
        nowCet.hour > 16 || (nowCet.hour == 16 && nowCet.minute >= 15);
    if (afterPublish) return true;
  }

  return false;
}

/// BYO / aggregator: refresh when missing or older than [minAge].
bool shouldRefreshThrottled({
  required RateSnapshot? cached,
  required DateTime nowUtc,
  Duration minAge = const Duration(minutes: 30),
  bool force = false,
}) {
  if (force) return true;
  if (cached == null) return true;
  return nowUtc.toUtc().difference(cached.fetchedAt.toUtc()) >= minAge;
}
