import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/id.dart';

class SessionRepository {
  SessionRepository(this._db);
  final AppDatabase _db;

  AppDatabase get db => _db;

  Future<String> startSession({
    required String userId,
    String? planDayId,
    required List<String> exerciseIds,
  }) async {
    final sessionId = newId();
    final now = DateTime.now().toUtc();

    await _db.transaction(() async {
      await _db.into(_db.sessions).insert(SessionsCompanion.insert(
            id: sessionId,
            userId: userId,
            planDayId: Value(planDayId),
            startedAt: now,
            status: const Value('in_progress'),
          ));
      for (var i = 0; i < exerciseIds.length; i++) {
        await _db.into(_db.sessionExercises).insert(
              SessionExercisesCompanion.insert(
                id: newId(),
                sessionId: sessionId,
                exerciseId: exerciseIds[i],
                order: i + 1,
              ),
            );
      }
      await _enqueue(sessionId, 'sessions', 'insert');
    });
    return sessionId;
  }

  Stream<SessionRow?> watchSession(String id) =>
      (_db.select(_db.sessions)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<SessionExerciseRow>> listExercises(String sessionId) {
    final q = _db.select(_db.sessionExercises)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm(expression: t.order)]);
    return q.get();
  }

  Stream<List<SessionExerciseRow>> watchExercises(String sessionId) {
    final q = _db.select(_db.sessionExercises)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm(expression: t.order)]);
    return q.watch();
  }

  Future<void> skipExercise(String sessionExerciseId, {String? reason}) async {
    await _db.transaction(() async {
      await (_db.update(_db.sessionExercises)..where((t) => t.id.equals(sessionExerciseId)))
          .write(
        SessionExercisesCompanion(
          status: const Value('skipped'),
          skipReason: Value(reason),
        ),
      );
      await _enqueue(sessionExerciseId, 'session_exercises', 'update');
    });
  }

  Future<void> markExerciseDone(String sessionExerciseId) async {
    await _db.transaction(() async {
      await (_db.update(_db.sessionExercises)..where((t) => t.id.equals(sessionExerciseId)))
          .write(const SessionExercisesCompanion(status: Value('done')));
      await _enqueue(sessionExerciseId, 'session_exercises', 'update');
    });
  }

  Future<void> resumeExercise(String sessionExerciseId) async {
    await _db.transaction(() async {
      await (_db.update(_db.sessionExercises)..where((t) => t.id.equals(sessionExerciseId)))
          .write(
        const SessionExercisesCompanion(
          status: Value('pending'),
          skipReason: Value(null),
        ),
      );
      await _enqueue(sessionExerciseId, 'session_exercises', 'update');
    });
  }

  Future<String> logSet({
    required String sessionExerciseId,
    required int setNumber,
    double? weight,
    required int reps,
    int? rir,
    int? restSeconds,
  }) async {
    final id = newId();
    await _db.transaction(() async {
      await _db.into(_db.sets).insert(SetsCompanion.insert(
            id: id,
            sessionExerciseId: sessionExerciseId,
            setNumber: setNumber,
            weight: Value(weight),
            reps: reps,
            rir: Value(rir),
            restSeconds: Value(restSeconds),
          ));
      await _enqueue(id, 'sets', 'insert');
    });
    return id;
  }

  Stream<List<SetRow>> watchSets(String sessionExerciseId) {
    final q = _db.select(_db.sets)
      ..where((t) => t.sessionExerciseId.equals(sessionExerciseId))
      ..orderBy([(t) => OrderingTerm(expression: t.setNumber)]);
    return q.watch();
  }

  Future<void> finishSession(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.sessions)..where((t) => t.id.equals(id))).write(
        SessionsCompanion(
          endedAt: Value(DateTime.now().toUtc()),
          status: const Value('completed'),
        ),
      );
      await _enqueue(id, 'sessions', 'update');
    });
  }

  Future<void> _enqueue(String id, String table, String op) async {
    await _db.into(_db.syncMetadata).insertOnConflictUpdate(
          SyncMetadataCompanion.insert(id: id, entityTable: table, operation: op),
        );
  }
}
