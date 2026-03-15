import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum CacheSyncState { neverSynced, synced, pendingSync, syncFailed }

enum CacheFreshness {
  freshServerBacked,
  cachedFresh,
  cachedStale,
  missing,
}

class CacheSnapshot {
  const CacheSnapshot({
    required this.hasData,
    required this.freshness,
    required this.syncState,
    this.lastFetchedAt,
    this.lastSyncedAt,
    this.lastMutationAt,
  });

  final bool hasData;
  final CacheFreshness freshness;
  final CacheSyncState syncState;
  final DateTime? lastFetchedAt;
  final DateTime? lastSyncedAt;
  final DateTime? lastMutationAt;

  bool get isStale => freshness == CacheFreshness.cachedStale;
}

class AppCacheStore {
  AppCacheStore(this._prefs);

  final SharedPreferences _prefs;

  String _metaKey(String scope, String key) => 'cache.meta.$scope.$key';
  String _payloadKey(String scope, String key) => 'cache.payload.$scope.$key';

  CacheSnapshot snapshot({
    required String scope,
    required String key,
    required Duration staleAfter,
  }) {
    final payloadExists = _prefs.containsKey(_payloadKey(scope, key));
    if (!payloadExists) {
      return const CacheSnapshot(
        hasData: false,
        freshness: CacheFreshness.missing,
        syncState: CacheSyncState.neverSynced,
      );
    }

    final metaJson = _prefs.getString(_metaKey(scope, key));
    if (metaJson == null || metaJson.isEmpty) {
      return const CacheSnapshot(
        hasData: true,
        freshness: CacheFreshness.cachedStale,
        syncState: CacheSyncState.neverSynced,
      );
    }

    final meta = Map<String, dynamic>.from(jsonDecode(metaJson) as Map);
    final lastFetchedAt = _parseDate(meta['last_fetched_at']);
    final lastSyncedAt = _parseDate(meta['last_synced_at']);
    final lastMutationAt = _parseDate(meta['last_mutation_at']);
    final syncState = _parseSyncState(meta['sync_state']?.toString());
    final isStale = _isStale(lastFetchedAt, staleAfter);
    final freshness =
        isStale ? CacheFreshness.cachedStale : CacheFreshness.cachedFresh;

    return CacheSnapshot(
      hasData: true,
      freshness: freshness,
      syncState: syncState,
      lastFetchedAt: lastFetchedAt,
      lastSyncedAt: lastSyncedAt,
      lastMutationAt: lastMutationAt,
    );
  }

  Future<void> storeMap({
    required String scope,
    required String key,
    required Map<String, dynamic> payload,
    bool markSynced = true,
  }) async {
    await _prefs.setString(_payloadKey(scope, key), jsonEncode(payload));
    await markFetched(scope: scope, key: key, markSynced: markSynced);
  }

  Future<void> storeList({
    required String scope,
    required String key,
    required List<Map<String, dynamic>> payload,
    bool markSynced = true,
  }) async {
    await _prefs.setString(_payloadKey(scope, key), jsonEncode(payload));
    await markFetched(scope: scope, key: key, markSynced: markSynced);
  }

  Map<String, dynamic>? readMap({
    required String scope,
    required String key,
  }) {
    final raw = _prefs.getString(_payloadKey(scope, key));
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  List<Map<String, dynamic>> readList({
    required String scope,
    required String key,
  }) {
    final raw = _prefs.getString(_payloadKey(scope, key));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<void> markFetched({
    required String scope,
    required String key,
    bool markSynced = true,
  }) async {
    final meta = _readMeta(scope, key);
    final now = DateTime.now();
    final next = <String, dynamic>{
      ...meta,
      'last_fetched_at': now.toIso8601String(),
      'sync_state':
          (markSynced ? CacheSyncState.synced : CacheSyncState.pendingSync)
              .name,
      if (markSynced) 'last_synced_at': now.toIso8601String(),
    };
    await _prefs.setString(_metaKey(scope, key), jsonEncode(next));
  }

  Future<void> markMutation({
    required String scope,
    required String key,
  }) async {
    final meta = _readMeta(scope, key);
    final now = DateTime.now();
    final next = <String, dynamic>{
      ...meta,
      'last_mutation_at': now.toIso8601String(),
      'sync_state': CacheSyncState.pendingSync.name,
    };
    await _prefs.setString(_metaKey(scope, key), jsonEncode(next));
  }

  Future<void> markSyncFailed({
    required String scope,
    required String key,
  }) async {
    final meta = _readMeta(scope, key);
    final next = <String, dynamic>{
      ...meta,
      'sync_state': CacheSyncState.syncFailed.name,
    };
    await _prefs.setString(_metaKey(scope, key), jsonEncode(next));
  }

  Future<void> invalidate({
    required String scope,
    required String key,
    bool removePayload = false,
  }) async {
    if (removePayload) {
      await _prefs.remove(_payloadKey(scope, key));
    }
    await _prefs.remove(_metaKey(scope, key));
  }

  Map<String, dynamic> _readMeta(String scope, String key) {
    final raw = _prefs.getString(_metaKey(scope, key));
    if (raw == null || raw.isEmpty) return const <String, dynamic>{};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static CacheSyncState _parseSyncState(String? value) {
    for (final state in CacheSyncState.values) {
      if (state.name == value) return state;
    }
    return CacheSyncState.neverSynced;
  }

  bool _isStale(DateTime? fetchedAt, Duration staleAfter) {
    if (fetchedAt == null) return true;
    return DateTime.now().difference(fetchedAt) > staleAfter;
  }
}
