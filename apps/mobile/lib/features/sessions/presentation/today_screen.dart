import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../exercises/presentation/widgets/sync_status_pill.dart';
import '../../plans/data/plan_repository.dart';
import '../data/session_repository.dart';

const _gap = 12.0;

final planRepoProvider = Provider<PlanRepository>(
  (ref) => PlanRepository(ref.watch(appDatabaseProvider)),
);

final sessionRepoProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(appDatabaseProvider)),
);

final _activePlanProvider = StreamProvider.autoDispose<PlanRow?>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(planRepoProvider).watchActivePlan(userId);
});

final _daysProvider = FutureProvider.autoDispose.family<List<PlanDayRow>, String>(
  (ref, planId) => ref.watch(planRepoProvider).daysFor(planId),
);

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  PlanDayRow _suggestedDay(List<PlanDayRow> days) {
    final idx = DateTime.now().toUtc().millisecondsSinceEpoch ~/
            Duration(days: 1).inMilliseconds %
        days.length;
    return days[idx];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(_activePlanProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: const [Padding(padding: EdgeInsets.all(8), child: SyncStatusPill())],
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) return const _EmptyState();
          final daysAsync = ref.watch(_daysProvider(plan.id));
          return daysAsync.when(
            data: (days) {
              if (days.isEmpty) return const _EmptyState();
              final suggested = _suggestedDay(days);
              final others = days.where((d) => d.id != suggested.id).toList();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DayCard(day: suggested, suggested: true),
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: _gap * 2),
                    const _SectionLabel(text: 'Or pick another day'),
                    const SizedBox(height: _gap),
                    for (final d in others) _DayCard(day: d),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No active plan. Generate one to start.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.day, this.suggested = false});

  final PlanDayRow day;
  final bool suggested;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final prescriptions = await ref.read(planRepoProvider).prescriptionsFor(day.id);
    final sessionId = await ref.read(sessionRepoProvider).startSession(
          userId: userId,
          planDayId: day.id,
          exerciseIds: prescriptions.map((p) => p.exerciseId).toList(),
        );
    if (context.mounted) unawaited(context.push('/session/$sessionId'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Card(
        child: ListTile(
          title: Text(day.name),
          subtitle: Text(day.focus),
          trailing: FilledButton(
            onPressed: () => unawaited(_start(context, ref)),
            child: Text(suggested ? 'Start' : 'Swap'),
          ),
        ),
      ),
    );
  }
}
