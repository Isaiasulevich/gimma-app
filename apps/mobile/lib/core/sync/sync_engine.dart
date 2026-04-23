import 'dart:async';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'sync_status.dart';

/// Server-side adapter. One method per entity kind.
abstract class SyncRemote {
  Future<void> pushExercise(Map<String, dynamic> row, String op);
  Future<void> pushSession(Map<String, dynamic> row, String op);
  Future<void> pushSessionExercise(Map<String, dynamic> row, String op);
  Future<void> pushSet(Map<String, dynamic> row, String op);
  Future<String?> uploadPhotoIfPresent({
    required String localPath,
    required String userId,
    required String exerciseId,
  });
}

class SyncEngine {
  SyncEngine({required AppDatabase db, required SyncRemote remote})
      : _db = db,
        _remote = remote;

  final AppDatabase _db;
  final SyncRemote _remote;
  final _stateCtrl = StreamController<SyncState>.broadcast();
  Timer? _ticker;
  bool _running = false;

  Stream<SyncState> get state => _stateCtrl.stream;

  /// Called when user is online.
  void start() {
    _ticker ??= Timer.periodic(const Duration(seconds: 60), (_) => unawaited(flush()));
    unawaited(flush());
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> flush() async {
    if (_running) return;
    _running = true;
    final pending = await _db.select(_db.syncMetadata).get();
    _stateCtrl.add(SyncState(phase: SyncPhase.syncing, pendingCount: pending.length));

    for (final row in pending) {
      try {
        await _pushOne(row);
        await (_db.delete(_db.syncMetadata)
              ..where((t) => t.id.equals(row.id) & t.entityTable.equals(row.entityTable)))
            .go();
      } catch (e) {
        await (_db.update(_db.syncMetadata)
              ..where((t) => t.id.equals(row.id) & t.entityTable.equals(row.entityTable)))
            .write(SyncMetadataCompanion(
          attemptCount: Value(row.attemptCount + 1),
          lastError: Value(e.toString()),
        ));
      }
    }

    final remaining = await _db.select(_db.syncMetadata).get();
    _stateCtrl.add(SyncState(
      phase: remaining.isEmpty ? SyncPhase.idle : SyncPhase.error,
      pendingCount: remaining.length,
      lastSyncedAt: DateTime.now().toUtc(),
    ));
    _running = false;
  }

  Future<void> _pushOne(SyncMetadataRow meta) async {
    switch (meta.entityTable) {
      case 'exercises':
        final row = await (_db.select(_db.exercises)..where((t) => t.id.equals(meta.id)))
            .getSingle();

        String? photoUrl = row.photoUrl;
        if (row.localPhotoPath != null && photoUrl == null && row.ownerUserId != null) {
          photoUrl = await _remote.uploadPhotoIfPresent(
            localPath: row.localPhotoPath!,
            userId: row.ownerUserId!,
            exerciseId: row.id,
          );
          if (photoUrl != null) {
            await (_db.update(_db.exercises)..where((t) => t.id.equals(row.id))).write(
              ExercisesCompanion(
                photoUrl: Value(photoUrl),
                localPhotoPath: const Value(null),
              ),
            );
          }
        }

        await _remote.pushExercise({
          'id': row.id,
          'owner_user_id': row.ownerUserId,
          'source': row.source,
          'source_ref': row.sourceRef,
          'name': row.name,
          'description': row.description,
          'photo_url': photoUrl,
          'primary_muscle': row.primaryMuscle,
          'secondary_muscles': row.secondaryMuscles,
          'equipment': row.equipment,
          'is_unilateral': row.isUnilateral,
          'is_archived': row.isArchived,
          'created_at': row.createdAt.toIso8601String(),
          'updated_at': row.updatedAt.toIso8601String(),
        }, meta.operation);
        break;
      case 'sessions':
        final row = await (_db.select(_db.sessions)..where((t) => t.id.equals(meta.id)))
            .getSingle();
        await _remote.pushSession({
          'id': row.id,
          'user_id': row.userId,
          'plan_day_id': row.planDayId,
          'started_at': row.startedAt.toIso8601String(),
          'ended_at': row.endedAt?.toIso8601String(),
          'status': row.status,
          'bodyweight': row.bodyweight,
          'heart_rate_avg': row.heartRateAvg,
          'heart_rate_max': row.heartRateMax,
          'calories_est': row.caloriesEst,
          'notes': row.notes,
        }, meta.operation);
        break;
      case 'session_exercises':
        final row =
            await (_db.select(_db.sessionExercises)..where((t) => t.id.equals(meta.id)))
                .getSingle();
        await _remote.pushSessionExercise({
          'id': row.id,
          'session_id': row.sessionId,
          'exercise_id': row.exerciseId,
          'order': row.order,
          'status': row.status,
          'skip_reason': row.skipReason,
        }, meta.operation);
        break;
      case 'sets':
        final row =
            await (_db.select(_db.sets)..where((t) => t.id.equals(meta.id))).getSingle();
        await _remote.pushSet({
          'id': row.id,
          'session_exercise_id': row.sessionExerciseId,
          'set_number': row.setNumber,
          'weight': row.weight,
          'reps': row.reps,
          'rir': row.rir,
          'rest_seconds': row.restSeconds,
          'tempo': row.tempo,
          'is_unilateral_left': row.isUnilateralLeft,
          'notes': row.notes,
          'logged_at': row.loggedAt.toIso8601String(),
        }, meta.operation);
        break;
      default:
        throw UnimplementedError('Unknown entity: ${meta.entityTable}');
    }
  }

  void dispose() {
    stop();
    _stateCtrl.close();
  }
}
