import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/core/db/app_database.dart';
import 'package:gimma/core/db/database_provider.dart';
import 'package:gimma/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows welcome title and sign-out action', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Gimma'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);

    await db.close();
  });
}
