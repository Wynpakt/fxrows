import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'rate_snapshot.dart';
import 'rates_provider.dart';

/// Persists the last successful [RateSnapshot] per provider for offline use.
class RateSnapshotCache {
  RateSnapshotCache({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static String _key(RatesProviderId id) => 'rate_snapshot_cache_${id.name}';

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<RateSnapshot?> load(RatesProviderId providerId) async {
    await _ensurePrefs();
    final raw = _prefs!.getString(_key(providerId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return RateSnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(RatesProviderId providerId, RateSnapshot snapshot) async {
    await _ensurePrefs();
    await _prefs!.setString(_key(providerId), jsonEncode(snapshot.toJson()));
  }

  Future<void> clear(RatesProviderId providerId) async {
    await _ensurePrefs();
    await _prefs!.remove(_key(providerId));
  }
}
