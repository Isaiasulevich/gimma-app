import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters.dart';
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
