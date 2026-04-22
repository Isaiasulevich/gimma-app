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
