import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_engine.dart';
import 'supabase_sync_remote.dart';

class SyncBootstrap {
  SyncBootstrap(this._engine);
  final SyncEngine _engine;
  StreamSubscription<dynamic>? _authSub;
  StreamSubscription<dynamic>? _connSub;

  void start() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        _engine.start();
      } else {
        _engine.stop();
      }
    });
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.isNotEmpty && results.any((c) => c != ConnectivityResult.none);
      if (online && Supabase.instance.client.auth.currentSession != null) {
        _engine.start();
      }
    });
  }

  void dispose() {
    _authSub?.cancel();
    _connSub?.cancel();
  }
}

final syncBootstrapProvider = Provider<SyncBootstrap>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final boot = SyncBootstrap(engine);
  ref.onDispose(boot.dispose);
  boot.start();
  return boot;
});
