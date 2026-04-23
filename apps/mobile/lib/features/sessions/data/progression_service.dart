import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class ProgressionService {
  ProgressionService(this._db);
  final AppDatabase _db;

  Future<SetRow?> lastSetFor(String exerciseId) async {
    final q = _db.select(_db.sets).join([
      innerJoin(
        _db.sessionExercises,
        _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId),
      ),
    ])
      ..where(_db.sessionExercises.exerciseId.equals(exerciseId))
      ..orderBy([OrderingTerm(expression: _db.sets.loggedAt, mode: OrderingMode.desc)])
      ..limit(1);
    final rows = await q.get();
    return rows.isEmpty ? null : rows.first.readTable(_db.sets);
  }

  /// True if `reps` at `weight` beats the best historical reps at `>= weight`.
  Future<bool> isPrForReps({
    required String exerciseId,
    required double weight,
    required int reps,
  }) async {
    final q = _db.select(_db.sets).join([
      innerJoin(
        _db.sessionExercises,
        _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId),
      ),
    ])
      ..where(
        _db.sessionExercises.exerciseId.equals(exerciseId) &
            _db.sets.weight.isNotNull() &
            _db.sets.weight.isBiggerOrEqualValue(weight),
      )
      ..orderBy([OrderingTerm(expression: _db.sets.reps, mode: OrderingMode.desc)])
      ..limit(1);
    final rows = await q.get();
    if (rows.isEmpty) return true;
    final best = rows.first.readTable(_db.sets);
    return reps > best.reps;
  }

  /// Volume (sets count) per primary-muscle over the last N days.
  Future<Map<String, int>> volumeByMuscle({
    required String userId,
    required int days,
  }) async {
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    final q = _db.select(_db.sets).join([
      innerJoin(
        _db.sessionExercises,
        _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId),
      ),
      innerJoin(
        _db.sessions,
        _db.sessions.id.equalsExp(_db.sessionExercises.sessionId),
      ),
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.sessionExercises.exerciseId),
      ),
    ])
      ..where(
        _db.sessions.userId.equals(userId) &
            _db.sessions.startedAt.isBiggerOrEqualValue(cutoff),
      );
    final rows = await q.get();
    final map = <String, int>{};
    for (final r in rows) {
      final ex = r.readTable(_db.exercises);
      map.update(ex.primaryMuscle, (v) => v + 1, ifAbsent: () => 1);
    }
    return map;
  }
}
