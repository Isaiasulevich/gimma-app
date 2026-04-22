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
