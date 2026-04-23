import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';
import 'hydrator.dart';
import 'sync_engine.dart';
import 'supabase_hydrate_source.dart';
import 'supabase_sync_remote.dart';

class SyncBootstrap {
  SyncBootstrap({required SyncEngine engine, required AppDatabase db})
      : _engine = engine,
        _db = db;

  final SyncEngine _engine;
  final AppDatabase _db;
  StreamSubscription<dynamic>? _authSub;
  StreamSubscription<dynamic>? _connSub;

  void start() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null) {
        _engine.start();
        await _hydrate(session.user.id);
      } else {
        _engine.stop();
      }
    });
    _connSub = Connectivity().onConnectivityChanged.listen((results) async {
      final online = results.isNotEmpty && results.any((c) => c != ConnectivityResult.none);
      if (online) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          _engine.start();
          await _hydrate(session.user.id);
        }
      }
    });
  }

  Future<void> _hydrate(String userId) async {
    try {
      final source = SupabaseHydrateSource(Supabase.instance.client);
      await Hydrator(db: _db, source: source).hydrate(userId: userId);
    } catch (_) {
      // Offline or transient failure — no-op; next connectivity event retries.
    }
  }

  void dispose() {
    _authSub?.cancel();
    _connSub?.cancel();
  }
}

final syncBootstrapProvider = Provider<SyncBootstrap>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final db = ref.watch(appDatabaseProvider);
  final boot = SyncBootstrap(engine: engine, db: db);
  ref.onDispose(boot.dispose);
  boot.start();
  return boot;
});
