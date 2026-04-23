import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import 'history_screen.dart' show historyRepositoryProvider;

const _gap = 12.0;

final _sessionExercisesProvider =
    FutureProvider.autoDispose.family<List<SessionExerciseRow>, String>(
  (ref, id) => ref.watch(historyRepositoryProvider).exercisesFor(id),
);

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({required this.sessionId, super.key});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_sessionExercisesProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Session detail')),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No exercises recorded.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _ExerciseBlock(sessionExercise: list[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ExerciseBlock extends ConsumerWidget {
  const _ExerciseBlock({required this.sessionExercise});
  final SessionExerciseRow sessionExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(historyRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap * 2),
      child: FutureBuilder<ExerciseRow?>(
        future: repo.exercise(sessionExercise.exerciseId),
        builder: (context, exSnap) {
          final exercise = exSnap.data;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise?.name ?? 'Exercise',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (sessionExercise.status == 'skipped')
                        Chip(
                          label: const Text('Skipped'),
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: _gap / 2),
                  _SetsList(sessionExerciseId: sessionExercise.id),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SetsList extends ConsumerWidget {
  const _SetsList({required this.sessionExerciseId});
  final String sessionExerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(historyRepositoryProvider);
    return FutureBuilder<List<SetRow>>(
      future: repo.setsFor(sessionExerciseId),
      builder: (context, snap) {
        final sets = snap.data ?? const <SetRow>[];
        if (sets.isEmpty) {
          return Text(
            'No sets logged.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return Column(
          children: [
            for (final s in sets)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${s.setNumber}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${s.weight?.toStringAsFixed(1) ?? '—'} kg × ${s.reps}'
                        '${s.rir != null ? ' @ RIR ${s.rir}' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
