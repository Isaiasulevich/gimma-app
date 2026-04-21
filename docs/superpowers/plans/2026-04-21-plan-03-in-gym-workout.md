# Plan 03: In-Gym Workout Flow — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the UX-critical in-gym workout flow — pick today's session (or swap), log sets with auto-rest timer, skip with re-prompt, finish with summary. All fully offline; syncs to Supabase when online. Also hydrates the local cache for active plan + recent sessions so the user can walk into the gym with everything pre-loaded.

**Architecture:** Extend the Drift schema from Plan 2 with `plans`, `plan_days`, `plan_prescriptions`, `sessions`, `session_exercises`, `sets`, plus a `hydration_metadata` table for tracking last-pulled timestamps per entity. A `SessionController` (Riverpod `AsyncNotifier`) owns the in-session state machine. `SyncEngine` is extended with new entity handlers.

**Tech Stack:** Drift · flutter_riverpod · vibration · audioplayers (rest-timer tone) · wakelock_plus (keep screen on during workout)

**Spec reference:** `docs/superpowers/specs/2026-04-21-gimma-gym-app-design.md` — §5.3–§5.4, §7 In-gym flow, §10 Resilience/caching.

**Depends on:** Plans 01 + 02.

---

## File structure produced by this plan

```
apps/mobile/lib/
├── core/db/tables/
│   ├── plans_table.dart
│   ├── plan_days_table.dart
│   ├── plan_prescriptions_table.dart
│   ├── sessions_table.dart
│   ├── session_exercises_table.dart
│   ├── sets_table.dart
│   └── hydration_metadata_table.dart
├── core/sync/
│   └── hydrator.dart             # initial + incremental pull from Supabase
├── features/
│   ├── plans/
│   │   └── data/plan_repository.dart
│   ├── sessions/
│   │   ├── data/
│   │   │   ├── session_repository.dart
│   │   │   └── progression_service.dart   # PR detection, pre-fill calc
│   │   └── presentation/
│   │       ├── today_screen.dart          # pick/swap
│   │       ├── session_screen.dart        # in-session state machine
│   │       ├── finish_screen.dart         # summary
│   │       ├── session_controller.dart
│   │       ├── rest_timer.dart            # countdown widget
│   │       └── widgets/
│   │           ├── set_row.dart
│   │           └── skip_chip.dart
test/
├── core/sync/hydrator_test.dart
└── features/sessions/
    ├── session_controller_test.dart
    └── progression_service_test.dart
```

---

## Task 1 — Add plan / session / set Drift tables

**Files:**
- Create: `apps/mobile/lib/core/db/tables/plans_table.dart`
- Create: `apps/mobile/lib/core/db/tables/plan_days_table.dart`
- Create: `apps/mobile/lib/core/db/tables/plan_prescriptions_table.dart`
- Create: `apps/mobile/lib/core/db/tables/sessions_table.dart`
- Create: `apps/mobile/lib/core/db/tables/session_exercises_table.dart`
- Create: `apps/mobile/lib/core/db/tables/sets_table.dart`
- Create: `apps/mobile/lib/core/db/tables/hydration_metadata_table.dart`
- Modify: `apps/mobile/lib/core/db/app_database.dart`

- [ ] **Step 1:** Write the plan-related tables.

`plans_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('PlanRow')
class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get goal => text()();
  TextColumn get packId => text().nullable()();
  TextColumn get splitType => text()();
  IntColumn get daysPerWeek => integer()();
  BoolColumn get generatedByAi => boolean().withDefault(const Constant(false))();
  TextColumn get aiReasoning => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

`plan_days_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('PlanDayRow')
class PlanDays extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  IntColumn get dayNumber => integer()();
  TextColumn get name => text()();
  TextColumn get focus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

`plan_prescriptions_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('PlanPrescriptionRow')
class PlanPrescriptions extends Table {
  TextColumn get id => text()();
  TextColumn get planDayId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get order => integer()();
  IntColumn get targetSets => integer()();
  IntColumn get targetRepsMin => integer()();
  IntColumn get targetRepsMax => integer()();
  IntColumn get targetRir => integer()();
  IntColumn get targetRestSeconds => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 2:** Write the session tables.

`sessions_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get planDayId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  RealColumn get bodyweight => real().nullable()();
  IntColumn get heartRateAvg => integer().nullable()();
  IntColumn get heartRateMax => integer().nullable()();
  IntColumn get caloriesEst => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

`session_exercises_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('SessionExerciseRow')
class SessionExercises extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get order => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get skipReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

`sets_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('SetRow')
class Sets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionExerciseId => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer()();
  IntColumn get rir => integer().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  TextColumn get tempo => text().nullable()();
  BoolColumn get isUnilateralLeft => boolean().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get loggedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 3:** Write the hydration metadata table.

`hydration_metadata_table.dart`:

```dart
import 'package:drift/drift.dart';

@DataClassName('HydrationMetadataRow')
class HydrationMetadata extends Table {
  TextColumn get entityTable => text()();
  DateTimeColumn get lastPulledAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityTable};
}
```

- [ ] **Step 4:** Update the database shell, bump schema version, add migration strategy.

Edit `apps/mobile/lib/core/db/app_database.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/exercises_table.dart';
import 'tables/hydration_metadata_table.dart';
import 'tables/plan_days_table.dart';
import 'tables/plan_prescriptions_table.dart';
import 'tables/plans_table.dart';
import 'tables/session_exercises_table.dart';
import 'tables/sessions_table.dart';
import 'tables/sets_table.dart';
import 'tables/sync_metadata_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Exercises,
  SyncMetadata,
  Plans,
  PlanDays,
  PlanPrescriptions,
  Sessions,
  SessionExercises,
  Sets,
  HydrationMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'gimma'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(plans);
            await m.createTable(planDays);
            await m.createTable(planPrescriptions);
            await m.createTable(sessions);
            await m.createTable(sessionExercises);
            await m.createTable(sets);
            await m.createTable(hydrationMetadata);
          }
        },
      );
}
```

- [ ] **Step 5:** Regenerate.

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/core/db
```

- [ ] **Step 6:** Commit.

```bash
git add apps/mobile/lib/core/db
git commit -m "feat(db): extend Drift with plans, sessions, sets, hydration metadata"
```

---

## Task 2 — Hydrator: pull active plan + recent sessions from Supabase

**Files:**
- Create: `apps/mobile/lib/core/sync/hydrator.dart`
- Create: `apps/mobile/test/core/sync/hydrator_test.dart`

The hydrator runs on sign-in and on explicit refresh. It fetches server
state into Drift for offline access.

- [ ] **Step 1:** Write failing tests with a fake hydrate source.

Write `apps/mobile/test/core/sync/hydrator_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/core/sync/hydrator.dart';

class _FakeSource implements HydrateSource {
  List<Map<String, dynamic>> plans = [];
  List<Map<String, dynamic>> planDays = [];
  List<Map<String, dynamic>> prescriptions = [];
  List<Map<String, dynamic>> sessions = [];
  List<Map<String, dynamic>> exercises = [];

  @override
  Future<List<Map<String, dynamic>>> fetchActivePlan(String userId) async => plans;
  @override
  Future<List<Map<String, dynamic>>> fetchPlanDays(List<String> planIds) async => planDays;
  @override
  Future<List<Map<String, dynamic>>> fetchPrescriptions(List<String> dayIds) async => prescriptions;
  @override
  Future<List<Map<String, dynamic>>> fetchRecentSessions(String userId, Duration window) async => sessions;
  @override
  Future<List<Map<String, dynamic>>> fetchVisibleExercises(String userId) async => exercises;
}

void main() {
  late AppDatabase db;
  late _FakeSource src;
  late Hydrator hydrator;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    src = _FakeSource();
    hydrator = Hydrator(db: db, source: src);
  });

  tearDown(() async => db.close());

  test('hydrate inserts active plan, days, prescriptions', () async {
    src.plans = [
      {
        'id': 'p1',
        'user_id': 'u',
        'name': 'PPL',
        'goal': 'muscle',
        'pack_id': 'hyp-v1',
        'split_type': 'ppl',
        'days_per_week': 5,
        'generated_by_ai': true,
        'ai_reasoning': 'balanced',
        'is_active': true,
        'started_at': '2026-04-01T00:00:00Z',
        'ended_at': null,
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      }
    ];
    src.planDays = [
      {'id': 'd1', 'plan_id': 'p1', 'day_number': 1, 'name': 'Push A', 'focus': 'chest'}
    ];
    src.prescriptions = [
      {
        'id': 'px1', 'plan_day_id': 'd1', 'exercise_id': 'e1', 'order': 1,
        'target_sets': 4, 'target_reps_min': 6, 'target_reps_max': 10,
        'target_rir': 2, 'target_rest_seconds': 180, 'notes': null,
      }
    ];

    await hydrator.hydrate(userId: 'u');

    expect((await db.select(db.plans).get()).map((p) => p.id), ['p1']);
    expect((await db.select(db.planDays).get()).map((d) => d.id), ['d1']);
    expect((await db.select(db.planPrescriptions).get()).map((px) => px.id), ['px1']);
  });
}
```

- [ ] **Step 2:** Implement the hydrator.

Write `apps/mobile/lib/core/sync/hydrator.dart`:

```dart
import 'package:drift/drift.dart';

import '../db/app_database.dart';

abstract class HydrateSource {
  Future<List<Map<String, dynamic>>> fetchActivePlan(String userId);
  Future<List<Map<String, dynamic>>> fetchPlanDays(List<String> planIds);
  Future<List<Map<String, dynamic>>> fetchPrescriptions(List<String> dayIds);
  Future<List<Map<String, dynamic>>> fetchRecentSessions(String userId, Duration window);
  Future<List<Map<String, dynamic>>> fetchVisibleExercises(String userId);
}

class Hydrator {
  Hydrator({required AppDatabase db, required HydrateSource source})
      : _db = db,
        _source = source;

  final AppDatabase _db;
  final HydrateSource _source;

  Future<void> hydrate({required String userId}) async {
    final plans = await _source.fetchActivePlan(userId);
    final planIds = plans.map((p) => p['id'] as String).toList();
    final days = planIds.isEmpty ? <Map<String, dynamic>>[] : await _source.fetchPlanDays(planIds);
    final dayIds = days.map((d) => d['id'] as String).toList();
    final prescriptions = dayIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await _source.fetchPrescriptions(dayIds);
    final sessions = await _source.fetchRecentSessions(userId, const Duration(days: 30));
    final exercises = await _source.fetchVisibleExercises(userId);

    await _db.transaction(() async {
      // Upsert exercises (seed + user's).
      for (final e in exercises) {
        await _db.into(_db.exercises).insertOnConflictUpdate(
              ExercisesCompanion.insert(
                id: e['id'] as String,
                ownerUserId: Value(e['owner_user_id'] as String?),
                source: e['source'] as String,
                sourceRef: Value(e['source_ref'] as String?),
                name: e['name'] as String,
                description: Value(e['description'] as String? ?? ''),
                photoUrl: Value(e['photo_url'] as String?),
                primaryMuscle: e['primary_muscle'] as String,
                secondaryMuscles: ((e['secondary_muscles'] as List?) ?? const [])
                    .cast<String>()
                    .toList(),
                equipment: e['equipment'] as String,
                isUnilateral: Value(e['is_unilateral'] as bool? ?? false),
                isArchived: Value(e['is_archived'] as bool? ?? false),
              ),
            );
      }

      for (final p in plans) {
        await _db.into(_db.plans).insertOnConflictUpdate(
              PlansCompanion.insert(
                id: p['id'] as String,
                userId: p['user_id'] as String,
                name: p['name'] as String,
                goal: p['goal'] as String,
                packId: Value(p['pack_id'] as String?),
                splitType: p['split_type'] as String,
                daysPerWeek: p['days_per_week'] as int,
                generatedByAi: Value(p['generated_by_ai'] as bool? ?? false),
                aiReasoning: Value(p['ai_reasoning'] as String?),
                isActive: Value(p['is_active'] as bool? ?? false),
                startedAt: Value(_parseDt(p['started_at'])),
                endedAt: Value(_parseDt(p['ended_at'])),
              ),
            );
      }

      for (final d in days) {
        await _db.into(_db.planDays).insertOnConflictUpdate(
              PlanDaysCompanion.insert(
                id: d['id'] as String,
                planId: d['plan_id'] as String,
                dayNumber: d['day_number'] as int,
                name: d['name'] as String,
                focus: d['focus'] as String,
              ),
            );
      }

      for (final px in prescriptions) {
        await _db.into(_db.planPrescriptions).insertOnConflictUpdate(
              PlanPrescriptionsCompanion.insert(
                id: px['id'] as String,
                planDayId: px['plan_day_id'] as String,
                exerciseId: px['exercise_id'] as String,
                order: px['order'] as int,
                targetSets: px['target_sets'] as int,
                targetRepsMin: px['target_reps_min'] as int,
                targetRepsMax: px['target_reps_max'] as int,
                targetRir: px['target_rir'] as int,
                targetRestSeconds: px['target_rest_seconds'] as int,
                notes: Value(px['notes'] as String?),
              ),
            );
      }

      for (final s in sessions) {
        await _db.into(_db.sessions).insertOnConflictUpdate(
              SessionsCompanion.insert(
                id: s['id'] as String,
                userId: s['user_id'] as String,
                planDayId: Value(s['plan_day_id'] as String?),
                startedAt: _parseDt(s['started_at'])!,
                endedAt: Value(_parseDt(s['ended_at'])),
                status: Value(s['status'] as String? ?? 'completed'),
              ),
            );
      }

      await _db.into(_db.hydrationMetadata).insertOnConflictUpdate(
            HydrationMetadataCompanion.insert(
              entityTable: 'active_plan',
              lastPulledAt: DateTime.now().toUtc(),
            ),
          );
    });
  }

  DateTime? _parseDt(dynamic v) => v == null ? null : DateTime.parse(v as String);
}
```

- [ ] **Step 3:** Run tests — expect PASS.

```bash
flutter test test/core/sync/hydrator_test.dart
```

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/lib/core/sync/hydrator.dart apps/mobile/test/core/sync/hydrator_test.dart
git commit -m "feat(sync): Hydrator pulls active plan + recent sessions into Drift"
```

---

## Task 3 — Supabase hydrate source implementation

**Files:**
- Create: `apps/mobile/lib/core/sync/supabase_hydrate_source.dart`
- Modify: `apps/mobile/lib/core/sync/sync_bootstrap.dart`

- [ ] **Step 1:** Write the Supabase implementation.

Write `apps/mobile/lib/core/sync/supabase_hydrate_source.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'hydrator.dart';

class SupabaseHydrateSource implements HydrateSource {
  SupabaseHydrateSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchActivePlan(String userId) async {
    final rows = await _client
        .from('plans')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPlanDays(List<String> planIds) async {
    if (planIds.isEmpty) return [];
    final rows = await _client.from('plan_days').select().inFilter('plan_id', planIds);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPrescriptions(List<String> dayIds) async {
    if (dayIds.isEmpty) return [];
    final rows = await _client
        .from('plan_prescriptions')
        .select()
        .inFilter('plan_day_id', dayIds);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecentSessions(String userId, Duration window) async {
    final cutoff = DateTime.now().toUtc().subtract(window).toIso8601String();
    final rows = await _client
        .from('sessions')
        .select()
        .eq('user_id', userId)
        .gte('started_at', cutoff);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchVisibleExercises(String userId) async {
    // RLS handles the visibility; we just ask for the full table.
    final rows = await _client.from('exercises').select().eq('is_archived', false);
    return List<Map<String, dynamic>>.from(rows);
  }
}
```

- [ ] **Step 2:** Run hydrator on sign-in.

Edit `apps/mobile/lib/core/sync/sync_bootstrap.dart` — after the auth listener fires with a session, call the hydrator:

```dart
_authSub = Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
  final session = event.session;
  if (session != null) {
    _engine.start();
    final hydrator = Hydrator(
      db: _db,
      source: SupabaseHydrateSource(Supabase.instance.client),
    );
    try {
      await hydrator.hydrate(userId: session.user.id);
    } catch (_) {
      // Offline at sign-in — fine, we'll hydrate on next connectivity event.
    }
  } else {
    _engine.stop();
  }
});
```

Add constructor dependency on `AppDatabase` — update `SyncBootstrap`:

```dart
class SyncBootstrap {
  SyncBootstrap(this._engine, this._db);
  final SyncEngine _engine;
  final AppDatabase _db;
  // ...
}

final syncBootstrapProvider = Provider<SyncBootstrap>((ref) {
  final engine = ref.watch(syncEngineProvider);
  final db = ref.watch(appDatabaseProvider);
  final boot = SyncBootstrap(engine, db);
  ref.onDispose(boot.dispose);
  boot.start();
  return boot;
});
```

Also add the connectivity-based re-hydrate: on `onConnectivityChanged`, if there's a session, call `hydrator.hydrate` after `engine.start()`.

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/core/sync/supabase_hydrate_source.dart \
        apps/mobile/lib/core/sync/sync_bootstrap.dart
git commit -m "feat(sync): hydrate active plan + recent history on sign-in"
```

---

## Task 4 — Plan repository

**Files:**
- Create: `apps/mobile/lib/features/plans/data/plan_repository.dart`

- [ ] **Step 1:** Write the repository.

```dart
import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class PlanRepository {
  PlanRepository(this._db);
  final AppDatabase _db;

  /// Returns the user's currently active plan, if any.
  Future<PlanRow?> activePlanFor(String userId) async {
    final q = _db.select(_db.plans)
      ..where((t) => t.userId.equals(userId) & t.isActive.equals(true))
      ..limit(1);
    final rows = await q.get();
    return rows.isEmpty ? null : rows.first;
  }

  Stream<PlanRow?> watchActivePlan(String userId) {
    final q = _db.select(_db.plans)
      ..where((t) => t.userId.equals(userId) & t.isActive.equals(true))
      ..limit(1);
    return q.watch().map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<List<PlanDayRow>> daysFor(String planId) async {
    final q = _db.select(_db.planDays)
      ..where((t) => t.planId.equals(planId))
      ..orderBy([(t) => OrderingTerm(expression: t.dayNumber)]);
    return q.get();
  }

  Future<List<PlanPrescriptionRow>> prescriptionsFor(String dayId) async {
    final q = _db.select(_db.planPrescriptions)
      ..where((t) => t.planDayId.equals(dayId))
      ..orderBy([(t) => OrderingTerm(expression: t.order)]);
    return q.get();
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/plans/data/plan_repository.dart
git commit -m "feat(plans): PlanRepository reads"
```

---

## Task 5 — Session repository

**Files:**
- Create: `apps/mobile/lib/features/sessions/data/session_repository.dart`

- [ ] **Step 1:** Implement.

```dart
import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/id.dart';

class SessionRepository {
  SessionRepository(this._db);
  final AppDatabase _db;

  Future<String> startSession({
    required String userId,
    required String planDayId,
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
        await _db.into(_db.sessionExercises).insert(SessionExercisesCompanion.insert(
              id: newId(),
              sessionId: sessionId,
              exerciseId: exerciseIds[i],
              order: i + 1,
            ));
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
      await (_db.update(_db.sessionExercises)..where((t) => t.id.equals(sessionExerciseId))).write(
        SessionExercisesCompanion(status: const Value('skipped'), skipReason: Value(reason)),
      );
      await _enqueue(sessionExerciseId, 'session_exercises', 'update');
    });
  }

  Future<void> markExerciseDone(String sessionExerciseId) async {
    await _db.transaction(() async {
      await (_db.update(_db.sessionExercises)..where((t) => t.id.equals(sessionExerciseId))).write(
        const SessionExercisesCompanion(status: Value('done')),
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
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/sessions/data/session_repository.dart
git commit -m "feat(sessions): local-first SessionRepository with outbox enqueue"
```

---

## Task 6 — Extend sync engine for new entities

**Files:**
- Modify: `apps/mobile/lib/core/sync/sync_engine.dart`
- Modify: `apps/mobile/lib/core/sync/supabase_sync_remote.dart`
- Modify: `apps/mobile/test/core/sync/sync_engine_test.dart`

- [ ] **Step 1:** Extend `SyncRemote` with session entity methods.

```dart
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
```

Extend `_pushOne` with cases for `sessions`, `session_exercises`, `sets`:

```dart
case 'sessions':
  final row = await (_db.select(_db.sessions)..where((t) => t.id.equals(meta.id))).getSingle();
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
  final row = await (_db.select(_db.sessionExercises)..where((t) => t.id.equals(meta.id))).getSingle();
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
  final row = await (_db.select(_db.sets)..where((t) => t.id.equals(meta.id))).getSingle();
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
```

- [ ] **Step 2:** Update Supabase remote. In `supabase_sync_remote.dart` add `pushSession`, `pushSessionExercise`, `pushSet` — all call `_client.from('<table>').upsert(row, onConflict: 'id')` for insert/update and `.delete().eq('id', row['id'])` for delete. Same pattern as `pushExercise`.

- [ ] **Step 3:** Update `_FakeRemote` in the sync test to implement the new methods (each records into a list, like `pushExercise`). Add assertions that session-related pushes happen.

- [ ] **Step 4:** Run tests — expect PASS.

- [ ] **Step 5:** Commit.

```bash
git add apps/mobile/lib/core/sync apps/mobile/test/core/sync/sync_engine_test.dart
git commit -m "feat(sync): push sessions, session_exercises, sets"
```

---

## Task 7 — Progression service (pre-fill + PR detection)

**Files:**
- Create: `apps/mobile/lib/features/sessions/data/progression_service.dart`
- Create: `apps/mobile/test/features/sessions/progression_service_test.dart`

- [ ] **Step 1:** Write failing tests.

```dart
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

  Future<String> _addExerciseAndSet({
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
    final exId = await _addExerciseAndSet(name: 'Bench', weight: 80, reps: 8, rir: 2);
    final last = await svc.lastSetFor(exId);
    expect(last?.weight, 80);
    expect(last?.reps, 8);
    expect(last?.rir, 2);
  });

  test('isPrForReps returns true when current reps exceed all prior at >= weight', () async {
    final exId = await _addExerciseAndSet(name: 'Bench', weight: 80, reps: 8);
    expect(await svc.isPrForReps(exerciseId: exId, weight: 80, reps: 10), isTrue);
    expect(await svc.isPrForReps(exerciseId: exId, weight: 80, reps: 8), isFalse);
  });
}
```

- [ ] **Step 2:** Implement.

```dart
import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class ProgressionService {
  ProgressionService(this._db);
  final AppDatabase _db;

  Future<SetRow?> lastSetFor(String exerciseId) async {
    final q = _db.select(_db.sets).join([
      innerJoin(_db.sessionExercises, _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId)),
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
      innerJoin(_db.sessionExercises, _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId)),
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

  /// Volume per primary-muscle over the last N days (deterministic, no AI).
  Future<Map<String, int>> volumeByMuscle({required String userId, required int days}) async {
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    final q = _db.select(_db.sets).join([
      innerJoin(_db.sessionExercises, _db.sessionExercises.id.equalsExp(_db.sets.sessionExerciseId)),
      innerJoin(_db.sessions, _db.sessions.id.equalsExp(_db.sessionExercises.sessionId)),
      innerJoin(_db.exercises, _db.exercises.id.equalsExp(_db.sessionExercises.exerciseId)),
    ])
      ..where(_db.sessions.userId.equals(userId) & _db.sessions.startedAt.isBiggerOrEqualValue(cutoff));
    final rows = await q.get();
    final map = <String, int>{};
    for (final r in rows) {
      final ex = r.readTable(_db.exercises);
      map.update(ex.primaryMuscle, (v) => v + 1, ifAbsent: () => 1);
    }
    return map;
  }
}
```

- [ ] **Step 3:** Run tests — expect PASS.

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/lib/features/sessions/data/progression_service.dart \
        apps/mobile/test/features/sessions/progression_service_test.dart
git commit -m "feat(sessions): progression service (pre-fill + PR + volume)"
```

---

## Task 8 — "Today" screen (pick + swap)

**Files:**
- Create: `apps/mobile/lib/features/sessions/presentation/today_screen.dart`
- Modify: `apps/mobile/lib/core/routing/app_router.dart`

- [ ] **Step 1:** Implement.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../plans/data/plan_repository.dart';
import '../data/session_repository.dart';

final planRepoProvider = Provider<PlanRepository>((ref) => PlanRepository(ref.watch(appDatabaseProvider)));
final sessionRepoProvider = Provider<SessionRepository>((ref) => SessionRepository(ref.watch(appDatabaseProvider)));

final _activePlanProvider = StreamProvider.autoDispose<PlanRow?>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(planRepoProvider).watchActivePlan(userId);
});

final _daysProvider = FutureProvider.autoDispose.family<List<PlanDayRow>, String>((ref, planId) {
  return ref.watch(planRepoProvider).daysFor(planId);
});

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  PlanDayRow _suggestedDay(List<PlanDayRow> days) {
    // Simple rotation by day-of-year.
    final idx = DateTime.now().dayOfYear % days.length;
    return days[idx];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(_activePlanProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('No active plan. Generate one to start.'));
          }
          final daysAsync = ref.watch(_daysProvider(plan.id));
          return daysAsync.when(
            data: (days) {
              if (days.isEmpty) return const Center(child: Text('Plan has no days.'));
              final suggested = _suggestedDay(days);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DayCard(day: suggested, suggested: true),
                  const SizedBox(height: 12),
                  const Text('Or pick another day'),
                  ...days.where((d) => d.id != suggested.id).map((d) => _DayCard(day: d)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.day, this.suggested = false});
  final PlanDayRow day;
  final bool suggested;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repo = ref.read(planRepoProvider);
    final prescriptions = await repo.prescriptionsFor(day.id);
    final sessionId = await ref.read(sessionRepoProvider).startSession(
          userId: userId,
          planDayId: day.id,
          exerciseIds: prescriptions.map((p) => p.exerciseId).toList(),
        );
    if (context.mounted) context.push('/session/$sessionId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(day.name),
        subtitle: Text(day.focus),
        trailing: FilledButton(
          onPressed: () => _start(context, ref),
          child: Text(suggested ? 'Start' : 'Swap'),
        ),
      ),
    );
  }
}

extension _Doy on DateTime {
  int get dayOfYear => difference(DateTime(year)).inDays + 1;
}
```

- [ ] **Step 2:** Add routes. Edit `app_router.dart`:

```dart
GoRoute(path: '/today', builder: (_, __) => const TodayScreen()),
GoRoute(path: '/session/:id', builder: (_, state) => SessionScreen(sessionId: state.pathParameters['id']!)),
GoRoute(path: '/session/:id/finish', builder: (_, state) => FinishScreen(sessionId: state.pathParameters['id']!)),
```

Add imports for `today_screen.dart`, `session_screen.dart`, `finish_screen.dart` (stubs will be added in next tasks).

- [ ] **Step 3:** Link from home screen.

Edit `home_screen.dart` — add a primary button `"Today"` linking to `/today`.

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/lib/features/sessions/presentation/today_screen.dart \
        apps/mobile/lib/core/routing/app_router.dart \
        apps/mobile/lib/features/home/presentation/home_screen.dart
git commit -m "feat(sessions): today screen — suggested + swap to start session"
```

---

## Task 9 — Session controller (state machine)

**Files:**
- Create: `apps/mobile/lib/features/sessions/presentation/session_controller.dart`
- Create: `apps/mobile/test/features/sessions/session_controller_test.dart`

The controller tracks which exercise/set the user is on, the rest-timer
state, and the list of skipped exercises to re-prompt at the end.

- [ ] **Step 1:** Write failing tests.

```dart
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/core/db/database_provider.dart';
import 'package:gimma/core/id.dart';
import 'package:gimma/features/sessions/data/session_repository.dart';
import 'package:gimma/features/sessions/presentation/session_controller.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<String> _seedSession({required int exerciseCount}) async {
    final sessionId = newId();
    await db.into(db.sessions).insert(SessionsCompanion.insert(
          id: sessionId,
          userId: 'u',
          startedAt: DateTime.now().toUtc(),
        ));
    for (var i = 0; i < exerciseCount; i++) {
      final exId = newId();
      await db.into(db.exercises).insert(ExercisesCompanion.insert(
            id: exId,
            source: 'user',
            name: 'E$i',
            primaryMuscle: 'chest',
            equipment: 'barbell',
            secondaryMuscles: const [],
          ));
      await db.into(db.sessionExercises).insert(SessionExercisesCompanion.insert(
            id: newId(),
            sessionId: sessionId,
            exerciseId: exId,
            order: i + 1,
          ));
    }
    return sessionId;
  }

  test('currentExercise points to first pending', () async {
    final sid = await _seedSession(exerciseCount: 3);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await container.read(sessionExercisesProvider(sid).future);
    final current = await container.read(currentExerciseProvider(sid).future);
    expect(current, isNotNull);
    expect(current!.order, 1);
  });

  test('skipExercise advances to next pending; re-promptable at end', () async {
    final sid = await _seedSession(exerciseCount: 3);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final exes = await container.read(sessionExercisesProvider(sid).future);
    final repo = SessionRepository(db);
    await repo.skipExercise(exes[0].id, reason: 'busy');

    container.invalidate(sessionExercisesProvider(sid));
    final next = await container.read(currentExerciseProvider(sid).future);
    expect(next!.order, 2);

    final skipped = await container.read(skippedExercisesProvider(sid).future);
    expect(skipped, hasLength(1));
    expect(skipped.first.id, exes[0].id);
  });
}
```

- [ ] **Step 2:** Implement.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
});

final sessionExercisesProvider =
    FutureProvider.autoDispose.family<List<SessionExerciseRow>, String>((ref, id) async {
  return ref.watch(sessionRepositoryProvider).listExercises(id);
});

final sessionExercisesStreamProvider =
    StreamProvider.autoDispose.family<List<SessionExerciseRow>, String>((ref, id) {
  return ref.watch(sessionRepositoryProvider).watchExercises(id);
});

final currentExerciseProvider =
    FutureProvider.autoDispose.family<SessionExerciseRow?, String>((ref, id) async {
  final list = await ref.watch(sessionExercisesProvider(id).future);
  try {
    return list.firstWhere((e) => e.status == 'pending' || e.status == 'in_progress');
  } catch (_) {
    return null;
  }
});

final skippedExercisesProvider =
    FutureProvider.autoDispose.family<List<SessionExerciseRow>, String>((ref, id) async {
  final list = await ref.watch(sessionExercisesProvider(id).future);
  return list.where((e) => e.status == 'skipped').toList();
});

final setsProvider = StreamProvider.autoDispose.family<List<SetRow>, String>((ref, seId) {
  return ref.watch(sessionRepositoryProvider).watchSets(seId);
});
```

- [ ] **Step 3:** Run tests — expect PASS.

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/lib/features/sessions/presentation/session_controller.dart \
        apps/mobile/test/features/sessions/session_controller_test.dart
git commit -m "feat(sessions): controller providers — current, skipped, sets"
```

---

## Task 10 — Rest timer widget

**Files:**
- Create: `apps/mobile/lib/features/sessions/presentation/rest_timer.dart`

- [ ] **Step 1:** Add dependencies.

```bash
cd apps/mobile
flutter pub add vibration audioplayers wakelock_plus
```

- [ ] **Step 2:** Implement the timer.

```dart
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class RestTimer extends StatefulWidget {
  const RestTimer({
    required this.durationSeconds,
    required this.onFinished,
    super.key,
  });

  final int durationSeconds;
  final VoidCallback onFinished;

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late int _remaining;
  Timer? _ticker;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _ticker?.cancel();
        _notifyEnd();
        widget.onFinished();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _notifyEnd() async {
    final hasVib = await Vibration.hasVibrator() ?? false;
    if (hasVib) Vibration.vibrate(duration: 500);
    await _player.play(AssetSource('sounds/timer-end.mp3'));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _player.dispose();
    super.dispose();
  }

  String get _display {
    final m = (_remaining ~/ 60).toString();
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_display,
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _remaining += 30),
              child: const Text('+30s'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                _ticker?.cancel();
                widget.onFinished();
              },
              child: const Text('Skip rest'),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 3:** Add a placeholder tone asset (bundle a short royalty-free MP3 at `apps/mobile/assets/sounds/timer-end.mp3`; if you don't have one, stub the `_player.play` call with a no-op for now).

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/sounds/timer-end.mp3
```

- [ ] **Step 4:** Commit.

```bash
git add apps/mobile/lib/features/sessions/presentation/rest_timer.dart \
        apps/mobile/pubspec.yaml apps/mobile/assets/sounds
git commit -m "feat(sessions): rest timer with haptic + tone"
```

---

## Task 11 — Session screen (core in-gym UI)

**Files:**
- Create: `apps/mobile/lib/features/sessions/presentation/session_screen.dart`
- Create: `apps/mobile/lib/features/sessions/presentation/widgets/set_row.dart`

- [ ] **Step 1:** Implement the set-row widget.

```dart
import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';

class SetRow extends StatelessWidget {
  const SetRow({required this.index, required this.set, super.key});
  final int index;
  final SetRow? set; // null for pending
  // ...
}
```

(Note: this naming collides with the table class; rename the widget to `SetRowView` to avoid confusion. Adjust imports accordingly.)

Rename and write `set_row_view.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';

class SetRowView extends StatelessWidget {
  const SetRowView({
    required this.index,
    this.set,
    this.targetWeight,
    this.targetReps,
    this.targetRir,
    this.isActive = false,
    super.key,
  });

  final int index;
  final SetRow? set;
  final double? targetWeight;
  final int? targetReps;
  final int? targetRir;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
      color: set == null && !isActive
          ? Theme.of(context).disabledColor
          : null,
    );
    final weight = set?.weight ?? targetWeight;
    final reps = set?.reps ?? targetReps;
    final rir = set?.rir ?? targetRir;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$index', style: style)),
          Expanded(child: Text(weight?.toStringAsFixed(1) ?? '—', style: style)),
          Expanded(child: Text(reps?.toString() ?? '—', style: style)),
          Expanded(child: Text(rir?.toString() ?? '—', style: style)),
          SizedBox(
            width: 24,
            child: set != null
                ? const Icon(Icons.check, color: Colors.green, size: 18)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2:** Implement the session screen.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/progression_service.dart';
import 'rest_timer.dart';
import 'session_controller.dart';
import 'widgets/set_row_view.dart';

final _progressionProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(ref.watch(appDatabaseProvider));
});

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({required this.sessionId, super.key});
  final String sessionId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  double? _weight;
  int? _reps;
  int? _rir;
  bool _resting = false;
  int _restSeconds = 120;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _prefill(String exerciseId, int targetRest) async {
    final last = await ref.read(_progressionProvider).lastSetFor(exerciseId);
    setState(() {
      _weight = last?.weight;
      _reps = last?.reps;
      _rir = last?.rir;
      _restSeconds = targetRest;
    });
  }

  Future<void> _logSet({
    required String sessionExerciseId,
    required int setNumber,
    required int targetRest,
  }) async {
    await ref.read(sessionRepositoryProvider).logSet(
          sessionExerciseId: sessionExerciseId,
          setNumber: setNumber,
          weight: _weight,
          reps: _reps ?? 0,
          rir: _rir,
          restSeconds: targetRest,
        );
    setState(() {
      _resting = true;
      _restSeconds = targetRest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAsync = ref.watch(currentExerciseProvider(widget.sessionId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
        actions: [
          TextButton(
            onPressed: () => context.push('/session/${widget.sessionId}/finish'),
            child: const Text('Finish'),
          ),
        ],
      ),
      body: currentAsync.when(
        data: (current) {
          if (current == null) {
            return const Center(
              child: Text('All exercises complete. Tap Finish to wrap up.'),
            );
          }
          return _ExerciseView(
            sessionExercise: current,
            sessionId: widget.sessionId,
            resting: _resting,
            restSeconds: _restSeconds,
            weight: _weight,
            reps: _reps,
            rir: _rir,
            onChangeWeight: (v) => setState(() => _weight = v),
            onChangeReps: (v) => setState(() => _reps = v),
            onChangeRir: (v) => setState(() => _rir = v),
            onLog: (setNumber, rest) => _logSet(
              sessionExerciseId: current.id,
              setNumber: setNumber,
              targetRest: rest,
            ),
            onRestDone: () => setState(() => _resting = false),
            onPrefillIfEmpty: () => _prefill(current.exerciseId, _restSeconds),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ExerciseView extends ConsumerWidget {
  const _ExerciseView({
    required this.sessionExercise,
    required this.sessionId,
    required this.resting,
    required this.restSeconds,
    required this.weight,
    required this.reps,
    required this.rir,
    required this.onChangeWeight,
    required this.onChangeReps,
    required this.onChangeRir,
    required this.onLog,
    required this.onRestDone,
    required this.onPrefillIfEmpty,
  });

  final SessionExerciseRow sessionExercise;
  final String sessionId;
  final bool resting;
  final int restSeconds;
  final double? weight;
  final int? reps;
  final int? rir;
  final ValueChanged<double> onChangeWeight;
  final ValueChanged<int> onChangeReps;
  final ValueChanged<int> onChangeRir;
  final void Function(int setNumber, int rest) onLog;
  final VoidCallback onRestDone;
  final VoidCallback onPrefillIfEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(setsProvider(sessionExercise.id));
    return setsAsync.when(
      data: (sets) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (sets.isEmpty) onPrefillIfEmpty();
        });
        final nextSet = sets.length + 1;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Exercise ${sessionExercise.order}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Weight',
                    value: weight,
                    onChanged: onChangeWeight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IntField(
                    label: 'Reps',
                    value: reps,
                    onChanged: onChangeReps,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IntField(
                    label: 'RIR',
                    value: rir,
                    onChanged: onChangeRir,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (resting)
              RestTimer(durationSeconds: restSeconds, onFinished: onRestDone)
            else
              FilledButton(
                onPressed: () => onLog(nextSet, restSeconds),
                child: Text('Log set $nextSet · start rest'),
              ),
            const SizedBox(height: 24),
            const _SetHeader(),
            ...sets.asMap().entries.map(
                  (e) => SetRowView(index: e.key + 1, set: e.value),
                ),
            SetRowView(
              index: nextSet,
              isActive: !resting,
              targetWeight: weight,
              targetReps: reps,
              targetRir: rir,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip (machine busy)'),
              onPressed: () async {
                await ref.read(sessionRepositoryProvider)
                    .skipExercise(sessionExercise.id, reason: 'machine busy');
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.done_all),
              label: const Text('Done with this exercise'),
              onPressed: () async {
                await ref.read(sessionRepositoryProvider).markExerciseDone(sessionExercise.id);
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _SetHeader extends StatelessWidget {
  const _SetHeader();
  @override
  Widget build(BuildContext context) => Row(
        children: const [
          SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text('KG', style: TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text('REPS', style: TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text('RIR', style: TextStyle(fontSize: 12, color: Colors.grey))),
          SizedBox(width: 24),
        ],
      );
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.value, required this.onChanged});
  final String label;
  final double? value;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value?.toStringAsFixed(1) ?? '');
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        final d = double.tryParse(v);
        if (d != null) onChanged(d);
      },
    );
  }
}

class _IntField extends StatelessWidget {
  const _IntField({required this.label, required this.value, required this.onChanged});
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value?.toString() ?? '');
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        final i = int.tryParse(v);
        if (i != null) onChanged(i);
      },
    );
  }
}
```

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/features/sessions/presentation/session_screen.dart \
        apps/mobile/lib/features/sessions/presentation/widgets/set_row_view.dart
git commit -m "feat(sessions): session screen — log set + rest timer + skip + done"
```

---

## Task 12 — Re-prompt skipped exercises

**Files:**
- Modify: `apps/mobile/lib/features/sessions/presentation/session_screen.dart`

- [ ] **Step 1:** When `currentExerciseProvider` returns null (all non-skipped exercises done), check if there are skipped ones. If yes, show a prompt in the body asking whether to do them now.

Replace the `currentAsync.when` `data` branch with:

```dart
data: (current) {
  if (current == null) {
    final skippedAsync = ref.watch(skippedExercisesProvider(widget.sessionId));
    return skippedAsync.when(
      data: (skipped) {
        if (skipped.isEmpty) {
          return const Center(
            child: Text('All exercises complete. Tap Finish to wrap up.'),
          );
        }
        return _SkippedRePrompt(
          sessionId: widget.sessionId,
          skipped: skipped,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
  return _ExerciseView(/* ... */);
},
```

Add `_SkippedRePrompt`:

```dart
class _SkippedRePrompt extends ConsumerWidget {
  const _SkippedRePrompt({required this.sessionId, required this.skipped});
  final String sessionId;
  final List<SessionExerciseRow> skipped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('You skipped ${skipped.length} exercise(s).',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...skipped.map((se) => Card(
              child: ListTile(
                title: Text('Exercise #${se.order}'),
                subtitle: Text(se.skipReason ?? ''),
                trailing: FilledButton(
                  onPressed: () async {
                    await ref.read(sessionRepositoryProvider)
                        .markExerciseDone(se.id); // soft-reset to let user log — simpler: set back to 'pending'
                  },
                  child: const Text('Do now'),
                ),
              ),
            )),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.push('/session/$sessionId/finish'),
          child: const Text('Finish anyway'),
        ),
      ],
    );
  }
}
```

Also add a method to `SessionRepository` to reset a skipped exercise back to pending (for the "Do now" button). Simpler: update status to `'pending'` and clear `skipReason`.

Edit `session_repository.dart`:

```dart
Future<void> resumeExercise(String sessionExerciseId) async {
  await _db.transaction(() async {
    await (_db.update(_db.sessionExercises)..where((t) => t.id.equals(sessionExerciseId))).write(
      const SessionExercisesCompanion(status: Value('pending'), skipReason: Value(null)),
    );
    await _enqueue(sessionExerciseId, 'session_exercises', 'update');
  });
}
```

Wire `Do now` to call `resumeExercise` instead of `markExerciseDone`.

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/sessions
git commit -m "feat(sessions): re-prompt skipped exercises before finish"
```

---

## Task 13 — Finish screen (summary)

**Files:**
- Create: `apps/mobile/lib/features/sessions/presentation/finish_screen.dart`

- [ ] **Step 1:** Implement.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/progression_service.dart';
import 'session_controller.dart';

class FinishScreen extends ConsumerWidget {
  const FinishScreen({required this.sessionId, super.key});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final sessionExercises = ref.watch(sessionExercisesStreamProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Session summary')),
      body: sessionExercises.when(
        data: (exes) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${exes.where((e) => e.status == 'done').length} of ${exes.length} exercises done',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              FutureBuilder(
                future: ProgressionService(ref.read(sessionRepositoryProvider).db).volumeByMuscle(
                  userId: userId,
                  days: 1,
                ),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final m = snap.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Volume today (sets)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...m.entries.map((e) => Text('${e.key}: ${e.value}')),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () async {
                  await ref.read(sessionRepositoryProvider).finishSession(sessionId);
                  if (context.mounted) context.go('/');
                },
                child: const Text('Finish & sync'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

Note: the `ProgressionService` construction uses the repository's `db`
getter — add a getter to `SessionRepository`:

```dart
AppDatabase get db => _db;
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/sessions/presentation/finish_screen.dart \
        apps/mobile/lib/features/sessions/data/session_repository.dart
git commit -m "feat(sessions): finish screen — summary + sync trigger"
```

---

## Task 14 — Manual smoke test (offline end-to-end)

- [ ] **Step 1:** Ensure an active plan exists in Supabase for your test user. Manually insert (via Studio) a minimal plan:

```sql
insert into public.plans (id, user_id, name, goal, split_type, days_per_week, is_active, started_at)
values ('p_test', '<YOUR_USER_ID>', 'Test PPL', 'muscle', 'ppl', 3, true, now());

insert into public.plan_days (id, plan_id, day_number, name, focus) values
  ('d1','p_test',1,'Push A','chest'),
  ('d2','p_test',2,'Pull A','back');

insert into public.plan_prescriptions (id, plan_day_id, exercise_id, "order", target_sets, target_reps_min, target_reps_max, target_rir, target_rest_seconds)
values
  ('px1','d1',(select id from public.exercises where name ilike 'Bench Press' limit 1),1,4,6,10,2,180),
  ('px2','d1',(select id from public.exercises where name ilike 'Overhead Press' limit 1),2,3,8,12,2,120);
```

- [ ] **Step 2:** In the app:
  - Sign in → Hydrator pulls plan + exercises
  - Home → Today → Push A suggested; Start
  - Log a set → rest timer starts
  - Skip the second exercise → finish first → re-prompt appears
  - Resume the skipped → log a set → Finish
  - Verify in Supabase Studio that `sessions`, `session_exercises`, `sets` all populated

- [ ] **Step 3:** Repeat with airplane mode on during the session — verify data syncs once back online (Sync pill goes Syncing N → Synced).

---

## Plan 3 Definition of Done

- [ ] Drift migrations run successfully (schema v2)
- [ ] Hydrator pulls active plan + 30-day session window on sign-in
- [ ] Today screen shows suggested session + swap options
- [ ] Sessions can be started, logged set-by-set, with auto-rest timer
- [ ] Skip with reason works; re-prompt appears after all non-skipped done
- [ ] Finish screen shows summary and finishes session
- [ ] All writes sync to Supabase when online; fully offline workout completes and syncs later
- [ ] `flutter test` passes (hydrator, progression, session controller, sync tests all green)

---

## Deferred

- **Pull-based conflict resolution** for sessions (server change → client change): out of v1. Sessions are append-only locally; conflicts are unlikely within one user's device.
- **Bodyweight, heart rate, calories** fields remain nullable and unused in v1 UI — populated when HealthKit lands in v2.
- **Mid-session chat** (swap today's squat): deferred to v1.5.
- **Custom rest times per-set override** — v1 uses the prescription's target rest; user can +30s / skip.
- **"Add exercise mid-session"** (user's Q13 clarification): stub the button but handle in Plan 3.5 / v1.5. For v1 MVP, the session's exercises are fixed to the plan_day's prescriptions.
