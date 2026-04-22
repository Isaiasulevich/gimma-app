import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import 'exercise_list_screen.dart' show exerciseRepositoryProvider;

final exerciseByIdProvider =
    FutureProvider.autoDispose.family<ExerciseRow, String>((ref, id) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.get(id);
});

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exerciseByIdProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: async.maybeWhen(
          data: (e) => Text(e.name),
          orElse: () => const Text('Exercise'),
        ),
      ),
      body: async.when(
        data: (e) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (e.photoUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  e.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _Placeholder(),
                ),
              )
            else
              const _Placeholder(),
            const SizedBox(height: 12),
            if (e.description.isNotEmpty)
              Text(e.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            _kv('Primary', e.primaryMuscle),
            _kv('Secondary', e.secondaryMuscles.join(', ')),
            _kv('Equipment', e.equipment),
            _kv('Unilateral', e.isUnilateral ? 'Yes' : 'No'),
            const SizedBox(height: 24),
            if (e.source == 'user')
              OutlinedButton.icon(
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive'),
                onPressed: () async {
                  await ref.read(exerciseRepositoryProvider).archive(e.id);
                  if (context.mounted) context.pop();
                },
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(k, style: const TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Text(v)),
          ],
        ),
      );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
        ),
      );
}
