import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

class PlanRepository {
  PlanRepository(this._db);
  final AppDatabase _db;

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
