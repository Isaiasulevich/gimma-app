import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class HistoryRepository {
  HistoryRepository(this._db);
  final AppDatabase _db;

  /// Completed sessions for the user, newest first.
  Stream<List<SessionRow>> watchCompleted(String userId) {
    final q = _db.select(_db.sessions)
      ..where((t) => t.userId.equals(userId) & t.status.equals('completed'))
      ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)]);
    return q.watch();
  }

  /// Exercises performed in a given session, in order.
  Future<List<SessionExerciseRow>> exercisesFor(String sessionId) {
    final q = _db.select(_db.sessionExercises)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm(expression: t.order)]);
    return q.get();
  }

  /// Sets logged for a session exercise.
  Future<List<SetRow>> setsFor(String sessionExerciseId) {
    final q = _db.select(_db.sets)
      ..where((t) => t.sessionExerciseId.equals(sessionExerciseId))
      ..orderBy([(t) => OrderingTerm(expression: t.setNumber)]);
    return q.get();
  }

  /// Look up an exercise's metadata.
  Future<ExerciseRow?> exercise(String id) async {
    final rows = await (_db.select(_db.exercises)..where((t) => t.id.equals(id))).get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Aggregate — total sets per session (for list subtitle).
  Future<int> totalSetsFor(String sessionId) async {
    final q = _db.selectOnly(_db.sets).join([
      innerJoin(
        _db.sessionExercises,
        _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId),
      ),
    ])
      ..where(_db.sessionExercises.sessionId.equals(sessionId))
      ..addColumns([_db.sets.id.count()]);
    final row = await q.getSingle();
    return row.read(_db.sets.id.count()) ?? 0;
  }
}
