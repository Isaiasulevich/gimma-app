import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gimma/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows welcome title and sign-out action', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Gimma'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
