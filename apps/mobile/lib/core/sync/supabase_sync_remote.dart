import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../db/database_provider.dart';
import 'sync_engine.dart';

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);
  final SupabaseClient _client;

  @override
  Future<void> pushExercise(Map<String, dynamic> row, String op) =>
      _pushRow('exercises', row, op);

  @override
  Future<void> pushSession(Map<String, dynamic> row, String op) =>
      _pushRow('sessions', row, op);

  @override
  Future<void> pushSessionExercise(Map<String, dynamic> row, String op) =>
      _pushRow('session_exercises', row, op);

  @override
  Future<void> pushSet(Map<String, dynamic> row, String op) =>
      _pushRow('sets', row, op);

  Future<void> _pushRow(String tableName, Map<String, dynamic> row, String op) async {
    final table = _client.from(tableName);
    switch (op) {
      case 'insert':
      case 'update':
        await table.upsert(row, onConflict: 'id');
        break;
      case 'delete':
        await table.delete().eq('id', row['id'] as String);
        break;
      default:
        throw ArgumentError('Unknown op $op');
    }
  }

  @override
  Future<String?> uploadPhotoIfPresent({
    required String localPath,
    required String userId,
    required String exerciseId,
  }) async {
    final storagePath = '$userId/$exerciseId.jpg';
    final bytes = await File(localPath).readAsBytes();
    await _client.storage.from('exercise-photos').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    return _client.storage.from('exercise-photos').getPublicUrl(storagePath);
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final remote = SupabaseSyncRemote(supabase);
  final engine = SyncEngine(db: db, remote: remote);
  ref.onDispose(engine.dispose);
  return engine;
});
