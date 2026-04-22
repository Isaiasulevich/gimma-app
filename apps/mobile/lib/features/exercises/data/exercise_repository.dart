import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/id.dart';

class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  Stream<List<ExerciseRow>> watchAll({String? muscleFilter}) {
    final q = _db.select(_db.exercises)
      ..where((t) => t.isArchived.equals(false));
    if (muscleFilter != null) {
      q.where((t) => t.primaryMuscle.equals(muscleFilter));
    }
    q.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return q.watch();
  }

  Future<ExerciseRow> get(String id) =>
      (_db.select(_db.exercises)..where((t) => t.id.equals(id))).getSingle();

  Future<String> createExercise({
    required String ownerUserId,
    required String name,
    String description = '',
    required String primaryMuscle,
    required List<String> secondaryMuscles,
    required String equipment,
    bool isUnilateral = false,
    String? localPhotoPath,
  }) async {
    final id = newId();
    final now = DateTime.now().toUtc();

    await _db.transaction(() async {
      await _db.into(_db.exercises).insert(
            ExercisesCompanion.insert(
              id: id,
              ownerUserId: Value(ownerUserId),
              source: 'user',
              name: name,
              description: Value(description),
              primaryMuscle: primaryMuscle,
              secondaryMuscles: secondaryMuscles,
              equipment: equipment,
              isUnilateral: Value(isUnilateral),
              localPhotoPath: Value(localPhotoPath),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await _enqueueSync(id, 'insert');
    });
    return id;
  }

  Future<void> update(String id, ExercisesCompanion patch) async {
    await _db.transaction(() async {
      await (_db.update(_db.exercises)..where((t) => t.id.equals(id))).write(
        patch.copyWith(updatedAt: Value(DateTime.now().toUtc())),
      );
      await _enqueueSync(id, 'update');
    });
  }

  Future<void> archive(String id) =>
      update(id, const ExercisesCompanion(isArchived: Value(true)));

  Future<void> _enqueueSync(String id, String operation) async {
    await _db.into(_db.syncMetadata).insertOnConflictUpdate(
          SyncMetadataCompanion.insert(
            id: id,
            entityTable: 'exercises',
            operation: operation,
          ),
        );
  }
}
