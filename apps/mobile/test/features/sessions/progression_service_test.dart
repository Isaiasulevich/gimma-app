import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/core/id.dart';
import 'package:gimma/features/sessions/data/progression_service.dart';

void main() {
  late AppDatabase db;
  late ProgressionService svc;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    svc = ProgressionService(db);
  });

  tearDown(() async => db.close());

  Future<String> seedExerciseAndSet({
    required String name,
    required double weight,
    required int reps,
    int? rir,
  }) async {
    final exId = newId();
    await db.into(db.exercises).insert(ExercisesCompanion.insert(
          id: exId,
          source: 'user',
          name: name,
          primaryMuscle: 'chest',
          equipment: 'barbell',
          secondaryMuscles: const [],
        ));
    final sessionId = newId();
    await db.into(db.sessions).insert(SessionsCompanion.insert(
          id: sessionId,
          userId: 'u',
          startedAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ));
    final seId = newId();
    await db.into(db.sessionExercises).insert(SessionExercisesCompanion.insert(
          id: seId,
          sessionId: sessionId,
          exerciseId: exId,
          order: 1,
        ));
    await db.into(db.sets).insert(SetsCompanion.insert(
          id: newId(),
          sessionExerciseId: seId,
          setNumber: 1,
          weight: Value(weight),
          reps: reps,
          rir: Value(rir),
        ));
    return exId;
  }

  test('lastSetFor returns the most recent set of an exercise', () async {
    final exId = await seedExerciseAndSet(
      name: 'Bench',
      weight: 80,
      reps: 8,
      rir: 2,
    );
    final last = await svc.lastSetFor(exId);
    expect(last?.weight, 80);
    expect(last?.reps, 8);
    expect(last?.rir, 2);
  });

  test('isPrForReps returns true when current reps exceed all prior at >= weight', () async {
    final exId = await seedExerciseAndSet(name: 'Bench', weight: 80, reps: 8);
    expect(await svc.isPrForReps(exerciseId: exId, weight: 80, reps: 10), isTrue);
    expect(await svc.isPrForReps(exerciseId: exId, weight: 80, reps: 8), isFalse);
  });
}
