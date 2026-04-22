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
