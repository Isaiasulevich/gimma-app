# Plan 02: Offline-first Exercise Library — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the local-first exercise library: bundle the yuhonas seed in the app, set up a Drift SQLite mirror of the server schema, write a sync engine, and deliver browse + create-custom-exercise UIs with offline photo upload queue.

**Architecture:** Drift is the local source of truth for the UI. An `ExerciseRepository` reads/writes Drift only; a `SyncEngine` background service pushes pending rows to Supabase and pulls server updates. Photos go through a queued upload pipeline (compress → stage locally → upload → update row). Seed data is bundled as a build-time asset and inserted on first launch if the local exercises table is empty.

**Tech Stack:** Drift (SQLite + code generation) · build_runner · image_picker · flutter_image_compress · uuid (v7 via `uuid_type`) · connectivity_plus · path_provider

**Spec reference:** `docs/superpowers/specs/2026-04-21-gimma-gym-app-design.md` — §5.2 Library, §5.6 RLS, §10 Offline sync.

**Depends on:** Plan 01 (schema, RLS, seed data in server DB, Flutter bootstrap, auth).

---

## File structure produced by this plan

```
apps/mobile/
├── assets/
│   └── seed/
│       └── exercises.json              # copied from supabase/seed_data at build
├── lib/
│   ├── core/
│   │   ├── db/
│   │   │   ├── app_database.dart       # Drift schema + generated code
│   │   │   ├── tables/
│   │   │   │   ├── exercises_table.dart
│   │   │   │   └── sync_metadata_table.dart
│   │   │   └── converters.dart
│   │   ├── sync/
│   │   │   ├── sync_engine.dart
│   │   │   ├── sync_status.dart
│   │   │   └── outbox.dart
│   │   └── id.dart                     # UUIDv7 generator
│   └── features/
│       └── exercises/
│           ├── data/
│           │   ├── exercise_repository.dart
│           │   ├── seed_loader.dart
│           │   └── photo_service.dart
│           └── presentation/
│               ├── exercise_list_screen.dart
│               ├── exercise_detail_screen.dart
│               ├── create_exercise_screen.dart
│               └── widgets/
│                   ├── exercise_tile.dart
│                   ├── muscle_picker.dart
│                   └── sync_status_pill.dart
├── test/
│   ├── core/sync/sync_engine_test.dart
│   └── features/exercises/
│       ├── exercise_repository_test.dart
│       └── exercise_list_screen_test.dart
└── build.yaml                          # Drift build_runner config
```

---

## Manual external setup

**M1 — Create a Supabase Storage bucket for exercise photos.**

Run once (either in Supabase Studio UI or SQL):

```sql
insert into storage.buckets (id, name, public)
values ('exercise-photos', 'exercise-photos', false);

create policy "users upload own photos"
  on storage.objects for insert
  with check (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users read own photos + seed photos"
  on storage.objects for select
  using (
    bucket_id = 'exercise-photos'
    and (auth.uid()::text = (storage.foldername(name))[1] or (storage.foldername(name))[1] = 'seed')
  );
```

Photo path convention: `exercise-photos/<user_id>/<exercise_id>.jpg` for user photos; seed images stay local (not in storage).

Commit these as `supabase/migrations/20260421000008_storage.sql`.

---

## Task 1 — Storage bucket migration

**Files:**
- Create: `supabase/migrations/20260421000008_storage.sql`

- [ ] **Step 1:** Write the migration.

```sql
insert into storage.buckets (id, name, public)
values ('exercise-photos', 'exercise-photos', false)
on conflict (id) do nothing;

create policy "users upload own photos"
  on storage.objects for insert
  with check (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users read own photos"
  on storage.objects for select
  using (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users update own photos"
  on storage.objects for update
  using (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "users delete own photos"
  on storage.objects for delete
  using (
    bucket_id = 'exercise-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
```

- [ ] **Step 2:** Apply and verify.

```bash
supabase db reset
supabase db execute "select id from storage.buckets where id='exercise-photos';"
```

Expected: one row.

- [ ] **Step 3:** Commit.

```bash
git add supabase/migrations/20260421000008_storage.sql
git commit -m "feat(storage): exercise-photos bucket with per-user RLS"
```

---

## Task 2 — Bundle seed JSON as Flutter asset

**Files:**
- Create: `apps/mobile/assets/seed/exercises.json` (symlink or copy)
- Modify: `apps/mobile/pubspec.yaml`

- [ ] **Step 1:** Copy seed data into the Flutter assets tree.

```bash
mkdir -p apps/mobile/assets/seed
cp supabase/seed_data/exercises.json apps/mobile/assets/seed/exercises.json
```

(We intentionally copy rather than symlink — Flutter's asset pipeline handles symlinks inconsistently across platforms.)

- [ ] **Step 2:** Register the asset in `apps/mobile/pubspec.yaml`.

Under the existing `flutter:` section:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/seed/exercises.json
```

- [ ] **Step 3:** Verify Flutter picks it up.

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter analyze
```

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/assets/seed/exercises.json apps/mobile/pubspec.yaml
git commit -m "feat(mobile): bundle yuhonas exercises.json as asset"
```

---

## Task 3 — Add Drift + codegen deps

**Files:**
- Modify: `apps/mobile/pubspec.yaml`
- Create: `apps/mobile/build.yaml`

- [ ] **Step 1:** Add runtime + dev deps.

```bash
cd apps/mobile
flutter pub add drift drift_flutter path path_provider sqlite3_flutter_libs uuid connectivity_plus image_picker flutter_image_compress
flutter pub add --dev drift_dev build_runner
```

- [ ] **Step 2:** Create `apps/mobile/build.yaml`.

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          sql:
            dialect: sqlite
          named_parameters: true
          apply_converters_on_variables: true
          generate_values_in_copy_with: true
```

- [ ] **Step 3:** Verify deps installed.

```bash
flutter pub get
flutter pub deps | grep drift
```

Expected: `drift`, `drift_dev`, `drift_flutter` listed.

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/pubspec.yaml apps/mobile/pubspec.lock apps/mobile/build.yaml
git commit -m "feat(mobile): add Drift and related deps"
```

---

## Task 4 — UUIDv7 helper

**Files:**
- Create: `apps/mobile/lib/core/id.dart`
- Create: `apps/mobile/test/core/id_test.dart`

- [ ] **Step 1:** Write the failing test.

Write `apps/mobile/test/core/id_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/id.dart';

void main() {
  test('newId returns 36-char UUID string', () {
    final id = newId();
    expect(id.length, 36);
    expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(id), isTrue);
  });

  test('newId generates monotonically increasing values within same ms', () async {
    final a = newId();
    final b = newId();
    // v7 UUIDs are sortable by time prefix.
    expect(a.compareTo(b), lessThanOrEqualTo(0));
  });
}
```

- [ ] **Step 2:** Run — expect FAIL.

```bash
flutter test test/core/id_test.dart
```

- [ ] **Step 3:** Implement `apps/mobile/lib/core/id.dart`.

```dart
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a UUIDv7 — time-ordered, safe for client-side generation,
/// used for idempotent sync (same ID on client and server).
String newId() => _uuid.v7();
```

- [ ] **Step 4:** Run — expect PASS.

```bash
flutter test test/core/id_test.dart
```

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/core/id.dart apps/mobile/test/core/id_test.dart
git commit -m "feat(core): UUIDv7 id generator"
```

---

## Task 5 — Drift tables (exercises + sync metadata)

**Files:**
- Create: `apps/mobile/lib/core/db/tables/exercises_table.dart`
- Create: `apps/mobile/lib/core/db/tables/sync_metadata_table.dart`
- Create: `apps/mobile/lib/core/db/converters.dart`
- Create: `apps/mobile/lib/core/db/app_database.dart`

- [ ] **Step 1:** Write string-list converter.

Write `apps/mobile/lib/core/db/converters.dart`:

```dart
import 'dart:convert';

import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (json.decode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => json.encode(value);
}
```

- [ ] **Step 2:** Write the exercises table.

Write `apps/mobile/lib/core/db/tables/exercises_table.dart`:

```dart
import 'package:drift/drift.dart';

import '../converters.dart';

@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUserId => text().nullable()();
  TextColumn get source => text()(); // 'seed' | 'user'
  TextColumn get sourceRef => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get localPhotoPath => text().nullable()(); // queued upload
  TextColumn get primaryMuscle => text()();
  TextColumn get secondaryMuscles => text().map(const StringListConverter())();
  TextColumn get equipment => text()();
  BoolColumn get isUnilateral => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 3:** Write the sync metadata table.

Write `apps/mobile/lib/core/db/tables/sync_metadata_table.dart`:

```dart
import 'package:drift/drift.dart';

/// Outbox of pending sync operations. Each row represents a local write
/// that needs to be pushed to the server. On success, the row is deleted.
@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  TextColumn get id => text()(); // UUID of the local row
  TextColumn get entityTable => text()(); // 'exercises', 'sessions', ...
  TextColumn get operation => text()(); // 'insert' | 'update' | 'delete'
  DateTimeColumn get queuedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id, entityTable};
}
```

- [ ] **Step 4:** Write the database shell (pre-codegen).

Write `apps/mobile/lib/core/db/app_database.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/exercises_table.dart';
import 'tables/sync_metadata_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Exercises, SyncMetadata])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'gimma'));

  @override
  int get schemaVersion => 1;
}
```

- [ ] **Step 5:** Run codegen.

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

Expected: `apps/mobile/lib/core/db/app_database.g.dart` is generated.

- [ ] **Step 6:** Verify analyzer.

```bash
flutter analyze lib/core/db
```

Expected: no issues.

- [ ] **Step 7:** Commit.

```bash
git add apps/mobile/lib/core/db
git commit -m "feat(db): Drift schema — exercises + sync_metadata"
```

---

## Task 6 — Database provider + first-launch init

**Files:**
- Create: `apps/mobile/lib/core/db/database_provider.dart`
- Modify: `apps/mobile/lib/main.dart`

- [ ] **Step 1:** Create the provider.

Write `apps/mobile/lib/core/db/database_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
```

- [ ] **Step 2:** Ensure the database opens on app start (no-op warmup to catch issues early).

Edit `apps/mobile/lib/main.dart` — after `await initSupabase();` add:

```dart
import 'core/db/app_database.dart';
// ...
final _warmupDb = AppDatabase();
await _warmupDb.close();
```

Actually simpler — just let it open lazily via the provider on first use. Skip the warmup. **Do not add the warmup code above; leave main.dart as-is.**

- [ ] **Step 3:** Verify analyzer.

```bash
flutter analyze lib/core/db
```

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/lib/core/db/database_provider.dart
git commit -m "feat(db): Riverpod provider for AppDatabase"
```

---

## Task 7 — Seed loader (first-launch asset insert)

**Files:**
- Create: `apps/mobile/lib/features/exercises/data/seed_loader.dart`
- Create: `apps/mobile/test/features/exercises/seed_loader_test.dart`

- [ ] **Step 1:** Write the failing test.

Write `apps/mobile/test/features/exercises/seed_loader_test.dart`:

```dart
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/features/exercises/data/seed_loader.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('loadSeedIfEmpty inserts rows when table empty', () async {
    final seedJson = jsonEncode([
      {
        'source': 'seed',
        'source_ref': 'yuhonas-1',
        'name': 'Bench Press',
        'description': 'Lie on a bench...',
        'primary_muscle': 'chest',
        'secondary_muscles': ['triceps', 'front_delts'],
        'equipment': 'barbell',
        'is_unilateral': false,
      }
    ]);
    await loadSeedIfEmpty(db, seedJson: seedJson);

    final rows = await db.select(db.exercises).get();
    expect(rows, hasLength(1));
    expect(rows.first.name, 'Bench Press');
    expect(rows.first.source, 'seed');
    expect(rows.first.secondaryMuscles, ['triceps', 'front_delts']);
  });

  test('loadSeedIfEmpty is a no-op when rows exist', () async {
    await db.into(db.exercises).insert(
          ExercisesCompanion.insert(
            id: 'x',
            source: 'user',
            name: 'Already Here',
            primaryMuscle: 'chest',
            equipment: 'barbell',
            secondaryMuscles: const [],
          ),
        );
    await loadSeedIfEmpty(db, seedJson: '[]');

    final rows = await db.select(db.exercises).get();
    expect(rows, hasLength(1));
    expect(rows.first.name, 'Already Here');
  });
}
```

- [ ] **Step 2:** Run — expect FAIL.

```bash
flutter test test/features/exercises/seed_loader_test.dart
```

- [ ] **Step 3:** Implement the loader.

Write `apps/mobile/lib/features/exercises/data/seed_loader.dart`:

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/db/app_database.dart';
import '../../../core/id.dart';

Future<void> loadSeedIfEmpty(AppDatabase db, {String? seedJson}) async {
  final count = await (db.selectOnly(db.exercises)..addColumns([db.exercises.id.count()]))
      .map((row) => row.read(db.exercises.id.count()))
      .getSingle();
  if ((count ?? 0) > 0) return;

  final raw = seedJson ?? await rootBundle.loadString('assets/seed/exercises.json');
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  final rows = list.map((e) => ExercisesCompanion.insert(
        id: newId(),
        source: e['source'] as String,
        sourceRef: Value(e['source_ref'] as String?),
        name: e['name'] as String,
        description: Value(e['description'] as String? ?? ''),
        primaryMuscle: e['primary_muscle'] as String,
        secondaryMuscles: ((e['secondary_muscles'] as List?) ?? const [])
            .cast<String>()
            .toList(),
        equipment: e['equipment'] as String,
        isUnilateral: Value(e['is_unilateral'] as bool? ?? false),
      ));

  await db.batch((batch) {
    batch.insertAll(db.exercises, rows.toList());
  });
}
```

- [ ] **Step 4:** Run — expect PASS.

```bash
flutter test test/features/exercises/seed_loader_test.dart
```

- [ ] **Step 5:** Wire into app boot.

Edit `apps/mobile/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/env.dart';
import 'config/supabase_bootstrap.dart';
import 'core/db/app_database.dart';
import 'features/exercises/data/seed_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await initSupabase();

  final db = AppDatabase();
  await loadSeedIfEmpty(db);
  await db.close();

  runApp(const ProviderScope(child: GimmaApp()));
}
```

- [ ] **Step 6:** Commit.

```bash
git add apps/mobile/lib/features/exercises/data/seed_loader.dart \
        apps/mobile/test/features/exercises/seed_loader_test.dart \
        apps/mobile/lib/main.dart
git commit -m "feat(exercises): load seed into local DB on first launch"
```

---

## Task 8 — Exercise repository (local-first CRUD)

**Files:**
- Create: `apps/mobile/lib/features/exercises/data/exercise_repository.dart`
- Create: `apps/mobile/test/features/exercises/exercise_repository_test.dart`

- [ ] **Step 1:** Write failing tests.

Write `apps/mobile/test/features/exercises/exercise_repository_test.dart`:

```dart
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
```

- [ ] **Step 2:** Run — expect FAIL.

- [ ] **Step 3:** Implement the repository.

Write `apps/mobile/lib/features/exercises/data/exercise_repository.dart`:

```dart
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

  Future<void> archive(String id) => update(id, const ExercisesCompanion(isArchived: Value(true)));

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

final class ExerciseDraft {
  const ExerciseDraft({
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    this.description = '',
    this.isUnilateral = false,
    this.localPhotoPath,
  });

  final String name;
  final String description;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final bool isUnilateral;
  final String? localPhotoPath;
}
```

- [ ] **Step 4:** Run — expect PASS.

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/features/exercises/data/exercise_repository.dart \
        apps/mobile/test/features/exercises/exercise_repository_test.dart
git commit -m "feat(exercises): local-first ExerciseRepository with sync outbox"
```

---

## Task 9 — Sync status types

**Files:**
- Create: `apps/mobile/lib/core/sync/sync_status.dart`

- [ ] **Step 1:** Define status types.

Write `apps/mobile/lib/core/sync/sync_status.dart`:

```dart
enum SyncPhase { idle, syncing, offline, error }

class SyncState {
  const SyncState({
    required this.phase,
    required this.pendingCount,
    this.lastError,
    this.lastSyncedAt,
  });

  final SyncPhase phase;
  final int pendingCount;
  final String? lastError;
  final DateTime? lastSyncedAt;

  SyncState copyWith({
    SyncPhase? phase,
    int? pendingCount,
    String? lastError,
    DateTime? lastSyncedAt,
  }) =>
      SyncState(
        phase: phase ?? this.phase,
        pendingCount: pendingCount ?? this.pendingCount,
        lastError: lastError,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );

  static const idle = SyncState(phase: SyncPhase.idle, pendingCount: 0);
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/core/sync/sync_status.dart
git commit -m "feat(sync): SyncState value type"
```

---

## Task 10 — Sync engine (TDD with a fake remote)

**Files:**
- Create: `apps/mobile/lib/core/sync/sync_engine.dart`
- Create: `apps/mobile/test/core/sync/sync_engine_test.dart`

- [ ] **Step 1:** Write failing tests with a fake remote.

Write `apps/mobile/test/core/sync/sync_engine_test.dart`:

```dart
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

    await engine.flush(); // first attempt fails
    var meta = await db.select(db.syncMetadata).get();
    expect(meta, hasLength(1));
    expect(meta.first.attemptCount, 1);

    await engine.flush(); // second attempt succeeds
    meta = await db.select(db.syncMetadata).get();
    expect(meta, isEmpty);
  });

  test('state emits pending count and phases', () async {
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

    // Allow stream to deliver.
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.any((s) => s.phase == SyncPhase.syncing), isTrue);
    expect(states.last.phase, anyOf(SyncPhase.idle, SyncPhase.syncing));
  });
}
```

- [ ] **Step 2:** Run — expect FAIL.

- [ ] **Step 3:** Implement the sync engine.

Write `apps/mobile/lib/core/sync/sync_engine.dart`:

```dart
import 'dart:async';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'sync_status.dart';

/// Server-side adapter. One method per entity kind.
abstract class SyncRemote {
  Future<void> pushExercise(Map<String, dynamic> row, String op);
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
        final row = await (_db.select(_db.exercises)..where((t) => t.id.equals(meta.id))).getSingle();
        await _remote.pushExercise({
          'id': row.id,
          'owner_user_id': row.ownerUserId,
          'source': row.source,
          'source_ref': row.sourceRef,
          'name': row.name,
          'description': row.description,
          'photo_url': row.photoUrl,
          'primary_muscle': row.primaryMuscle,
          'secondary_muscles': row.secondaryMuscles,
          'equipment': row.equipment,
          'is_unilateral': row.isUnilateral,
          'is_archived': row.isArchived,
          'created_at': row.createdAt.toIso8601String(),
          'updated_at': row.updatedAt.toIso8601String(),
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
```

- [ ] **Step 4:** Run — expect PASS.

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/core/sync/sync_engine.dart \
        apps/mobile/test/core/sync/sync_engine_test.dart
git commit -m "feat(sync): SyncEngine with outbox, retry, and state stream"
```

---

## Task 11 — Supabase sync remote implementation

**Files:**
- Create: `apps/mobile/lib/core/sync/supabase_sync_remote.dart`

- [ ] **Step 1:** Implement `SupabaseSyncRemote`.

Write `apps/mobile/lib/core/sync/supabase_sync_remote.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../db/app_database.dart';
import 'sync_engine.dart';

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);
  final SupabaseClient _client;

  @override
  Future<void> pushExercise(Map<String, dynamic> row, String op) async {
    final table = _client.from('exercises');
    switch (op) {
      case 'insert':
      case 'update':
        // upsert handles both — server has ON CONFLICT via primary key.
        await table.upsert(row, onConflict: 'id');
        break;
      case 'delete':
        await table.delete().eq('id', row['id'] as String);
        break;
      default:
        throw ArgumentError('Unknown op $op');
    }
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(_appDbProvider);
  final remote = SupabaseSyncRemote(supabase);
  final engine = SyncEngine(db: db, remote: remote);
  ref.onDispose(engine.dispose);
  return engine;
});

// Re-export so the test file doesn't depend on this provider.
final _appDbProvider = Provider<AppDatabase>((ref) => throw UnimplementedError(
      'Override _appDbProvider with appDatabaseProvider in ProviderScope.',
    ));
```

Actually, reuse the existing `appDatabaseProvider` — edit this file to:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../db/database_provider.dart';
import 'sync_engine.dart';

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);
  final SupabaseClient _client;

  @override
  Future<void> pushExercise(Map<String, dynamic> row, String op) async {
    final table = _client.from('exercises');
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
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final remote = SupabaseSyncRemote(supabase);
  final engine = SyncEngine(db: db, remote: remote);
  ref.onDispose(engine.dispose);
  return engine;
});
```

- [ ] **Step 2:** Analyzer clean.

```bash
flutter analyze lib/core/sync
```

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/core/sync/supabase_sync_remote.dart
git commit -m "feat(sync): Supabase implementation of SyncRemote"
```

---

## Task 12 — Auto-start sync on auth + connectivity

**Files:**
- Create: `apps/mobile/lib/core/sync/sync_bootstrap.dart`
- Modify: `apps/mobile/lib/app.dart`

- [ ] **Step 1:** Write the bootstrap listener.

Write `apps/mobile/lib/core/sync/sync_bootstrap.dart`:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_engine.dart';
import 'supabase_sync_remote.dart';

final syncBootstrapProvider = Provider<SyncBootstrap>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final boot = SyncBootstrap(engine);
  ref.onDispose(boot.dispose);
  boot.start();
  return boot;
});

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
    _connSub = Connectivity().onConnectivityChanged.listen((r) {
      final online = r.isNotEmpty && r.any((c) => c != ConnectivityResult.none);
      if (online) _engine.start();
    });
  }

  void dispose() {
    _authSub?.cancel();
    _connSub?.cancel();
  }
}
```

- [ ] **Step 2:** Warm it up from `app.dart`.

Edit `apps/mobile/lib/app.dart` — add `ref.watch(syncBootstrapProvider);` inside `build`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/sync/sync_bootstrap.dart';
import 'core/theme/app_theme.dart';

class GimmaApp extends ConsumerWidget {
  const GimmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncBootstrapProvider); // fire-and-forget
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Gimma',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/core/sync/sync_bootstrap.dart apps/mobile/lib/app.dart
git commit -m "feat(sync): auto-start on auth + connectivity change"
```

---

## Task 13 — Photo service (pick, compress, stage, upload)

**Files:**
- Create: `apps/mobile/lib/features/exercises/data/photo_service.dart`

- [ ] **Step 1:** Implement the photo service.

Write `apps/mobile/lib/features/exercises/data/photo_service.dart`:

```dart
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoService {
  PhotoService(this._supabase);
  final SupabaseClient _supabase;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndStage({required ImageSource source}) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (xfile == null) return null;

    final compressed = await FlutterImageCompress.compressWithFile(
      xfile.path,
      minWidth: 800,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final stagingDir = Directory(p.join(dir.path, 'photo_staging'));
    if (!stagingDir.existsSync()) {
      await stagingDir.create(recursive: true);
    }
    final filename = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final stagedPath = p.join(stagingDir.path, filename);
    await File(stagedPath).writeAsBytes(compressed);
    return stagedPath;
  }

  /// Uploads a staged photo to Supabase Storage. Returns the public URL.
  Future<String> upload({
    required String localPath,
    required String userId,
    required String exerciseId,
  }) async {
    final storagePath = '$userId/$exerciseId.jpg';
    final bytes = await File(localPath).readAsBytes();
    await _supabase.storage.from('exercise-photos').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    final url = _supabase.storage.from('exercise-photos').getPublicUrl(storagePath);
    return url;
  }

  Future<void> deleteStaged(String localPath) async {
    final f = File(localPath);
    if (f.existsSync()) {
      await f.delete();
    }
  }
}
```

- [ ] **Step 2:** Platform permissions.

**iOS** — edit `apps/mobile/ios/Runner/Info.plist`, add inside `<dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Gimma uses your photo library to attach exercise photos.</string>
<key>NSCameraUsageDescription</key>
<string>Gimma uses your camera to capture exercise photos.</string>
```

**Android** — no extra permission needed for `image_picker` on API 33+; on older versions the plugin handles it.

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/features/exercises/data/photo_service.dart \
        apps/mobile/ios/Runner/Info.plist
git commit -m "feat(exercises): photo picker + compressor + Storage upload"
```

---

## Task 14 — Extend sync to handle photo upload side-effect

**Files:**
- Modify: `apps/mobile/lib/core/sync/sync_engine.dart`
- Modify: `apps/mobile/lib/core/sync/supabase_sync_remote.dart`

- [ ] **Step 1:** Extend `SyncRemote` with a photo-upload hook.

Edit `apps/mobile/lib/core/sync/sync_engine.dart` — add an abstract method:

```dart
abstract class SyncRemote {
  Future<void> pushExercise(Map<String, dynamic> row, String op);
  Future<String?> uploadPhotoIfPresent({
    required String localPath,
    required String userId,
    required String exerciseId,
  });
}
```

In `_pushOne`, before the push, if `row.localPhotoPath != null && row.photoUrl == null`, upload the photo and update the row's `photo_url` both locally and in the outgoing payload:

```dart
case 'exercises':
  final row = await (_db.select(_db.exercises)..where((t) => t.id.equals(meta.id))).getSingle();

  String? photoUrl = row.photoUrl;
  if (row.localPhotoPath != null && photoUrl == null) {
    photoUrl = await _remote.uploadPhotoIfPresent(
      localPath: row.localPhotoPath!,
      userId: row.ownerUserId!,
      exerciseId: row.id,
    );
    if (photoUrl != null) {
      await (_db.update(_db.exercises)..where((t) => t.id.equals(row.id))).write(
        ExercisesCompanion(photoUrl: Value(photoUrl), localPhotoPath: const Value(null)),
      );
    }
  }

  await _remote.pushExercise({
    // ... same as before, but photo_url: photoUrl
    'photo_url': photoUrl,
    // ... rest
  }, meta.operation);
  break;
```

- [ ] **Step 2:** Implement on Supabase side.

Edit `apps/mobile/lib/core/sync/supabase_sync_remote.dart`:

```dart
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// ... existing imports

class SupabaseSyncRemote implements SyncRemote {
  // ... existing code

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
```

- [ ] **Step 3:** Update the fake remote in the sync test to match the new interface.

Edit `apps/mobile/test/core/sync/sync_engine_test.dart` — add to `_FakeRemote`:

```dart
@override
Future<String?> uploadPhotoIfPresent({
  required String localPath,
  required String userId,
  required String exerciseId,
}) async => null;
```

- [ ] **Step 4:** Run tests — expect PASS.

```bash
flutter test
```

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/core/sync apps/mobile/test/core/sync/sync_engine_test.dart
git commit -m "feat(sync): upload queued photos before pushing exercise row"
```

---

## Task 15 — Exercise list screen

**Files:**
- Create: `apps/mobile/lib/features/exercises/presentation/exercise_list_screen.dart`
- Create: `apps/mobile/lib/features/exercises/presentation/widgets/exercise_tile.dart`
- Create: `apps/mobile/test/features/exercises/exercise_list_screen_test.dart`
- Modify: `apps/mobile/lib/core/routing/app_router.dart`

- [ ] **Step 1:** Write a widget test with an in-memory DB.

Write `apps/mobile/test/features/exercises/exercise_list_screen_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/core/db/database_provider.dart';
import 'package:gimma/features/exercises/data/exercise_repository.dart';
import 'package:gimma/features/exercises/presentation/exercise_list_screen.dart';

void main() {
  testWidgets('shows exercises from repo', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ExerciseRepository(db);
    await repo.createExercise(
      ownerUserId: 'u',
      name: 'Bench Press',
      primaryMuscle: 'chest',
      secondaryMuscles: const [],
      equipment: 'barbell',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ExerciseListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);

    await db.close();
  });
}
```

- [ ] **Step 2:** Run — expect FAIL.

- [ ] **Step 3:** Implement the tile.

Write `apps/mobile/lib/features/exercises/presentation/widgets/exercise_tile.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({required this.exercise, this.onTap, super.key});

  final ExerciseRow exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        child: Text(exercise.primaryMuscle.substring(0, 1).toUpperCase()),
      ),
      title: Text(exercise.name),
      subtitle: Text('${exercise.primaryMuscle} · ${exercise.equipment}'),
      trailing: exercise.source == 'user'
          ? const Icon(Icons.person_outline, size: 18)
          : null,
    );
  }
}
```

- [ ] **Step 4:** Implement the list screen.

Write `apps/mobile/lib/features/exercises/presentation/exercise_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/exercise_repository.dart';
import 'widgets/exercise_tile.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExerciseRepository(db);
});

final exercisesStreamProvider = StreamProvider<List<ExerciseRow>>((ref) {
  return ref.watch(exerciseRepositoryProvider).watchAll();
});

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncExercises = ref.watch(exercisesStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/exercises/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: asyncExercises.when(
              data: (rows) {
                final filtered = _query.isEmpty
                    ? rows
                    : rows.where((e) => e.name.toLowerCase().contains(_query)).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No exercises'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ExerciseTile(
                    exercise: filtered[i],
                    onTap: () => context.push('/exercises/${filtered[i].id}'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5:** Wire into router.

Edit `apps/mobile/lib/core/routing/app_router.dart` — add routes under the existing `routes:` list:

```dart
GoRoute(path: '/exercises', builder: (_, __) => const ExerciseListScreen()),
GoRoute(path: '/exercises/new', builder: (_, __) => const CreateExerciseScreen()),
GoRoute(path: '/exercises/:id', builder: (_, state) => ExerciseDetailScreen(id: state.pathParameters['id']!)),
```

Add imports at the top of the file:

```dart
import '../../features/exercises/presentation/create_exercise_screen.dart';
import '../../features/exercises/presentation/exercise_detail_screen.dart';
import '../../features/exercises/presentation/exercise_list_screen.dart';
```

(Stubs for `CreateExerciseScreen` and `ExerciseDetailScreen` are created in the next tasks — router imports will fail until then; that's expected.)

- [ ] **Step 6:** Run the list screen's widget test — expect PASS.

```bash
flutter test test/features/exercises/exercise_list_screen_test.dart
```

- [ ] **Step 7:** Commit.

```bash
git add apps/mobile/lib/features/exercises/presentation/exercise_list_screen.dart \
        apps/mobile/lib/features/exercises/presentation/widgets/exercise_tile.dart \
        apps/mobile/test/features/exercises/exercise_list_screen_test.dart \
        apps/mobile/lib/core/routing/app_router.dart
git commit -m "feat(exercises): list screen with search + navigation"
```

---

## Task 16 — Muscle picker widget

**Files:**
- Create: `apps/mobile/lib/features/exercises/presentation/widgets/muscle_picker.dart`

- [ ] **Step 1:** Write the widget.

Write `apps/mobile/lib/features/exercises/presentation/widgets/muscle_picker.dart`:

```dart
import 'package:flutter/material.dart';

const kAllMuscles = [
  'chest','upper_back','lats','traps','lower_back',
  'front_delts','side_delts','rear_delts',
  'biceps','triceps','forearms',
  'quads','hamstrings','glutes','calves','adductors','abductors',
  'abs','obliques','neck','core',
];

class MusclePicker extends StatelessWidget {
  const MusclePicker({
    required this.selected,
    required this.onChanged,
    this.multi = false,
    super.key,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kAllMuscles.map((m) {
        final isSelected = selected.contains(m);
        return FilterChip(
          label: Text(m.replaceAll('_', ' ')),
          selected: isSelected,
          onSelected: (_) {
            final next = {...selected};
            if (multi) {
              if (isSelected) {
                next.remove(m);
              } else {
                next.add(m);
              }
            } else {
              next
                ..clear()
                ..add(m);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/exercises/presentation/widgets/muscle_picker.dart
git commit -m "feat(exercises): muscle picker chips (single or multi)"
```

---

## Task 17 — Create exercise screen

**Files:**
- Create: `apps/mobile/lib/features/exercises/presentation/create_exercise_screen.dart`

- [ ] **Step 1:** Implement the form.

Write `apps/mobile/lib/features/exercises/presentation/create_exercise_screen.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/exercise_repository.dart';
import '../data/photo_service.dart';
import 'exercise_list_screen.dart' show exerciseRepositoryProvider;
import 'widgets/muscle_picker.dart';

final _photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService(Supabase.instance.client);
});

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _primary;
  final _secondary = <String>{};
  String _equipment = 'barbell';
  bool _isUnilateral = false;
  String? _photoPath;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photoService = ref.read(_photoServiceProvider);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final path = await photoService.pickAndStage(source: source);
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _primary == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    final repo = ref.read(exerciseRepositoryProvider);
    await repo.createExercise(
      ownerUserId: userId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      primaryMuscle: _primary!,
      secondaryMuscles: _secondary.toList(),
      equipment: _equipment,
      isUnilateral: _isUnilateral,
      localPhotoPath: _photoPath,
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New exercise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickPhoto,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _photoPath == null
                  ? const Center(child: Text('+ Add photo'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_photoPath!), fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Primary muscle', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          MusclePicker(
            selected: _primary == null ? <String>{} : <String>{_primary!},
            onChanged: (s) => setState(() => _primary = s.firstOrNull),
          ),
          const SizedBox(height: 16),
          const Text('Secondary muscles', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          MusclePicker(
            selected: _secondary,
            multi: true,
            onChanged: (s) => setState(() {
              _secondary
                ..clear()
                ..addAll(s);
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _equipment,
            decoration: const InputDecoration(labelText: 'Equipment'),
            items: const [
              DropdownMenuItem(value: 'barbell', child: Text('Barbell')),
              DropdownMenuItem(value: 'dumbbell', child: Text('Dumbbell')),
              DropdownMenuItem(value: 'machine', child: Text('Machine')),
              DropdownMenuItem(value: 'cable', child: Text('Cable')),
              DropdownMenuItem(value: 'bodyweight', child: Text('Bodyweight')),
              DropdownMenuItem(value: 'band', child: Text('Band')),
              DropdownMenuItem(value: 'kettlebell', child: Text('Kettlebell')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _equipment = v!),
          ),
          SwitchListTile(
            title: const Text('Unilateral (single limb)'),
            value: _isUnilateral,
            onChanged: (v) => setState(() => _isUnilateral = v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/exercises/presentation/create_exercise_screen.dart
git commit -m "feat(exercises): create-exercise form with photo + muscles"
```

---

## Task 18 — Exercise detail screen

**Files:**
- Create: `apps/mobile/lib/features/exercises/presentation/exercise_detail_screen.dart`

- [ ] **Step 1:** Implement detail + archive.

Write `apps/mobile/lib/features/exercises/presentation/exercise_detail_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import 'exercise_list_screen.dart' show exerciseRepositoryProvider;

final exerciseByIdProvider =
    FutureProvider.autoDispose.family<ExerciseRow, String>((ref, id) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.get(id);
});

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exerciseByIdProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: async.maybeWhen(data: (e) => Text(e.name), orElse: () => const Text('Exercise')),
      ),
      body: async.when(
        data: (e) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (e.photoUrl != null || e.localPhotoPath != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: e.photoUrl != null
                    ? Image.network(e.photoUrl!, fit: BoxFit.cover)
                    : const ColoredBox(color: Colors.black12),
              ),
            const SizedBox(height: 12),
            Text(e.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            _kv('Primary', e.primaryMuscle),
            _kv('Secondary', e.secondaryMuscles.join(', ')),
            _kv('Equipment', e.equipment),
            _kv('Unilateral', e.isUnilateral ? 'Yes' : 'No'),
            const SizedBox(height: 24),
            if (e.source == 'user')
              OutlinedButton.icon(
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive'),
                onPressed: () async {
                  await ref.read(exerciseRepositoryProvider).archive(e.id);
                  if (context.mounted) context.pop();
                },
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text(k, style: const TextStyle(color: Colors.grey))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/exercises/presentation/exercise_detail_screen.dart
git commit -m "feat(exercises): detail screen with archive for user-created"
```

---

## Task 19 — Sync status pill in app chrome

**Files:**
- Create: `apps/mobile/lib/features/exercises/presentation/widgets/sync_status_pill.dart`
- Modify: `apps/mobile/lib/features/home/presentation/home_screen.dart`
- Modify: `apps/mobile/lib/features/exercises/presentation/exercise_list_screen.dart`

- [ ] **Step 1:** Write the pill.

Write `apps/mobile/lib/features/exercises/presentation/widgets/sync_status_pill.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/supabase_sync_remote.dart';
import '../../../../core/sync/sync_status.dart';

final _syncStateProvider = StreamProvider<SyncState>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.state;
});

class SyncStatusPill extends ConsumerWidget {
  const SyncStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_syncStateProvider);
    final state = async.value ?? SyncState.idle;
    final (bg, fg, label) = switch (state.phase) {
      SyncPhase.idle when state.pendingCount == 0 =>
        (Colors.green.shade100, Colors.green.shade900, 'Synced'),
      SyncPhase.syncing =>
        (Colors.blue.shade100, Colors.blue.shade900, 'Syncing ${state.pendingCount}'),
      SyncPhase.offline => (Colors.grey.shade300, Colors.grey.shade800, 'Offline'),
      SyncPhase.error =>
        (Colors.orange.shade100, Colors.orange.shade900, '${state.pendingCount} pending'),
      _ => (Colors.grey.shade200, Colors.grey.shade800, 'Syncing'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
```

- [ ] **Step 2:** Add the pill to home + exercises appbars (left-of-actions).

In each screen's `AppBar`, change the `actions:` list to prepend the pill:

```dart
actions: [
  const Padding(padding: EdgeInsets.all(8), child: SyncStatusPill()),
  // ... existing buttons
],
```

Add the import in both files:

```dart
import '../../exercises/presentation/widgets/sync_status_pill.dart';
```

(For `exercise_list_screen.dart`, the relative path is `widgets/sync_status_pill.dart`.)

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/features/exercises/presentation/widgets/sync_status_pill.dart \
        apps/mobile/lib/features/home/presentation/home_screen.dart \
        apps/mobile/lib/features/exercises/presentation/exercise_list_screen.dart
git commit -m "feat(sync): SyncStatusPill in home + exercise list"
```

---

## Task 20 — Manual smoke test + Home screen linking

**Files:**
- Modify: `apps/mobile/lib/features/home/presentation/home_screen.dart`

- [ ] **Step 1:** Give the home screen a way to jump to Exercises.

Edit `apps/mobile/lib/features/home/presentation/home_screen.dart` — body becomes:

```dart
body: Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'Training features arrive in later plans.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.fitness_center),
          label: const Text('Exercises'),
          onPressed: () => context.push('/exercises'),
        ),
      ],
    ),
  ),
),
```

Add the import:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2:** Manual smoke test.

```bash
cd apps/mobile
flutter run
```

Walk through:
1. Sign in
2. Home → "Exercises" → seed library appears
3. Turn airplane mode on → tap "+" → create exercise with photo → save
4. Turn airplane mode off → verify pill changes to "Syncing N" then "Synced"
5. Supabase Studio → `exercises` table → new row present with your photo URL
6. Archive a custom exercise → list updates

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/features/home/presentation/home_screen.dart
git commit -m "feat(home): link to Exercises"
```

---

## Plan 2 Definition of Done

- [ ] `exercise-photos` storage bucket exists with per-user RLS
- [ ] Seed JSON is bundled in the app and loaded on first launch
- [ ] `flutter test` passes including sync engine tests
- [ ] Drift codegen is checked in (or regenerated deterministically)
- [ ] Airplane-mode smoke test passes: create exercise offline → sync when online → row in Supabase with photo URL
- [ ] Exercise list shows seed + user entries; search works; archive hides user-created
- [ ] `SyncStatusPill` reflects real state (idle / syncing / pending)
- [ ] `flutter analyze` has no issues

---

## Deferred to later plans

- **Sessions + sets sync** → Plan 3 (adds new entity kinds to `SyncRemote`)
- **Pulling server changes** (conflict resolution with server `updated_at`) → added in Plan 3 when workouts need pull
- **Photo display from `photo_url`** → currently shows if present; richer CDN handling in Plan 8 polish
- **Exercise edit (not just archive)** → Plan 2.5 / v1.5 if it hurts; out of v1 DoD
- **Muscle enum source of truth sharing between client and server** — the Dart constant list in `muscle_picker.dart` duplicates the Postgres enum. Acceptable debt for v1; revisit with code generation in Plan 8 if it drifts.
