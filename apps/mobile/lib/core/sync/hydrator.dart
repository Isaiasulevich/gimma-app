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
    final days = planIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await _source.fetchPlanDays(planIds);
    final dayIds = days.map((d) => d['id'] as String).toList();
    final prescriptions = dayIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await _source.fetchPrescriptions(dayIds);
    final sessions =
        await _source.fetchRecentSessions(userId, const Duration(days: 30));
    final exercises = await _source.fetchVisibleExercises(userId);

    await _db.transaction(() async {
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
