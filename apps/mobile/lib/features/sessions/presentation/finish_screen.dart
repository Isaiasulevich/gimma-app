import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import 'session_controller.dart';
import 'session_screen.dart' show progressionProvider;
import 'today_screen.dart' show sessionRepoProvider;

const _gap = 12.0;

class FinishScreen extends ConsumerWidget {
  const FinishScreen({required this.sessionId, super.key});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final exes = ref.watch(sessionExercisesStreamProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Session summary')),
      body: exes.when(
        data: (list) => _Summary(
          userId: userId,
          exercises: list,
          onFinish: () => unawaited(_finish(context, ref)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionRepoProvider).finishSession(sessionId);
    if (context.mounted) context.go('/history');
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({
    required this.userId,
    required this.exercises,
    required this.onFinish,
  });

  final String userId;
  final List<SessionExerciseRow> exercises;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = exercises.where((e) => e.status == 'done').length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '$done of ${exercises.length} exercises done',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: _gap * 2),
        _VolumeSection(userId: userId),
        const SizedBox(height: _gap * 3),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onFinish,
            child: const Text('Finish & sync'),
          ),
        ),
      ],
    );
  }
}

class _VolumeSection extends ConsumerWidget {
  const _VolumeSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.watch(progressionProvider);
    return FutureBuilder<Map<String, int>>(
      future: svc.volumeByMuscle(userId: userId, days: 1),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final m = snap.data!;
        if (m.isEmpty) {
          return Text(
            'No sets logged yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume today (sets by muscle)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: _gap / 2),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final entry in m.entries)
                  Chip(label: Text('${entry.key}: ${entry.value}')),
              ],
            ),
          ],
        );
      },
    );
  }
}
