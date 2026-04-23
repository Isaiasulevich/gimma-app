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
  Future<List<Map<String, dynamic>>> fetchPrescriptions(List<String> dayIds) async =>
      prescriptions;

  @override
  Future<List<Map<String, dynamic>>> fetchRecentSessions(String userId, Duration window) async =>
      sessions;

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

  test('hydrate inserts active plan, days, prescriptions, and session rows', () async {
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
    final exId = '00000000-0000-7000-8000-000000000001';
    src.exercises = [
      {
        'id': exId,
        'owner_user_id': null,
        'source': 'seed',
        'source_ref': 'ex1',
        'name': 'Bench',
        'description': '',
        'photo_url': null,
        'primary_muscle': 'chest',
        'secondary_muscles': <String>[],
        'equipment': 'barbell',
        'is_unilateral': false,
        'is_archived': false,
      }
    ];
    src.prescriptions = [
      {
        'id': 'px1',
        'plan_day_id': 'd1',
        'exercise_id': exId,
        'order': 1,
        'target_sets': 4,
        'target_reps_min': 6,
        'target_reps_max': 10,
        'target_rir': 2,
        'target_rest_seconds': 180,
        'notes': null,
      }
    ];

    await hydrator.hydrate(userId: 'u');

    expect((await db.select(db.plans).get()).map((p) => p.id), ['p1']);
    expect((await db.select(db.planDays).get()).map((d) => d.id), ['d1']);
    expect((await db.select(db.planPrescriptions).get()).map((px) => px.id), ['px1']);
    expect((await db.select(db.exercises).get()).map((e) => e.id), [exId]);
  });

  test('hydrate is a no-op when source returns empty', () async {
    await hydrator.hydrate(userId: 'u');
    expect(await db.select(db.plans).get(), isEmpty);
  });
}
