import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/exercise_repository.dart';
import 'widgets/exercise_tile.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExerciseRepository(db);
});

final exercisesStreamProvider = StreamProvider<List<ExerciseRow>>((ref) {
  return ref.watch(exerciseRepositoryProvider).watchAll();
});

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncExercises = ref.watch(exercisesStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/exercises/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: asyncExercises.when(
              data: (rows) {
                final filtered = _query.isEmpty
                    ? rows
                    : rows.where((e) => e.name.toLowerCase().contains(_query)).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No exercises'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ExerciseTile(
                    exercise: filtered[i],
                    onTap: () => context.push('/exercises/${filtered[i].id}'),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
