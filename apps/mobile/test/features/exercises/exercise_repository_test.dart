import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/features/exercises/data/exercise_repository.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ExerciseRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('createExercise inserts and enqueues sync', () async {
    final id = await repo.createExercise(
      ownerUserId: 'user-1',
      name: 'Incline DB Press',
      description: 'Upper chest focus',
      primaryMuscle: 'chest',
      secondaryMuscles: const ['front_delts', 'triceps'],
      equipment: 'dumbbell',
      isUnilateral: false,
    );

    final row = await (db.select(db.exercises)..where((t) => t.id.equals(id))).getSingle();
    expect(row.name, 'Incline DB Press');
    expect(row.source, 'user');

    final meta = await db.select(db.syncMetadata).get();
    expect(meta, hasLength(1));
    expect(meta.first.id, id);
    expect(meta.first.entityTable, 'exercises');
    expect(meta.first.operation, 'insert');
  });

  test('watchAll emits exercises filtered by archived flag', () async {
    await repo.createExercise(
      ownerUserId: 'user-1',
      name: 'Visible',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );
    final archivedId = await repo.createExercise(
      ownerUserId: 'user-1',
      name: 'Hidden',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );
    await repo.archive(archivedId);

    final visible = await repo.watchAll().first;
    expect(visible.map((e) => e.name), ['Visible']);
  });
}
