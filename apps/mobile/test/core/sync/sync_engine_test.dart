import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/core/sync/sync_engine.dart';
import 'package:gimma/core/sync/sync_status.dart';
import 'package:gimma/features/exercises/data/exercise_repository.dart';

class _FakeRemote implements SyncRemote {
  final List<Map<String, dynamic>> pushed = [];
  bool throwOnce = false;

  @override
  Future<void> pushExercise(Map<String, dynamic> row, String op) async {
    if (throwOnce) {
      throwOnce = false;
      throw Exception('transient');
    }
    pushed.add({...row, '_op': op});
  }

  @override
  Future<String?> uploadPhotoIfPresent({
    required String localPath,
    required String userId,
    required String exerciseId,
  }) async => null;
}

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;
  late _FakeRemote remote;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ExerciseRepository(db);
    remote = _FakeRemote();
    engine = SyncEngine(db: db, remote: remote);
  });

  tearDown(() async {
    await db.close();
  });

  test('flush pushes all pending exercises and clears outbox on success', () async {
    await repo.createExercise(
      ownerUserId: 'u',
      name: 'E1',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );
    await repo.createExercise(
      ownerUserId: 'u',
      name: 'E2',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );

    await engine.flush();

    expect(remote.pushed, hasLength(2));
    final meta = await db.select(db.syncMetadata).get();
    expect(meta, isEmpty);
  });

  test('flush retries on transient error and eventually clears', () async {
    await repo.createExercise(
      ownerUserId: 'u',
      name: 'E',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );
    remote.throwOnce = true;

    await engine.flush();
    var meta = await db.select(db.syncMetadata).get();
    expect(meta, hasLength(1));
    expect(meta.first.attemptCount, 1);

    await engine.flush();
    meta = await db.select(db.syncMetadata).get();
    expect(meta, isEmpty);
  });

  test('state stream emits phases during flush', () async {
    final states = <SyncState>[];
    final sub = engine.state.listen(states.add);

    await repo.createExercise(
      ownerUserId: 'u',
      name: 'E',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );
    await engine.flush();

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.any((s) => s.phase == SyncPhase.syncing), isTrue);
    expect(states.last.phase, anyOf(SyncPhase.idle, SyncPhase.syncing));
  });
}
