import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../exercises/presentation/widgets/sync_status_pill.dart';
import '../../onboarding/data/onboarding_state_provider.dart';
import '../../onboarding/presentation/ready_for_plan_sheet.dart';
import '../../plans/data/plan_repository.dart';
import '../data/session_repository.dart';

const _gap = 12.0;

// Observation-mode auto-prompt thresholds.
const _readyForPlanDays = 14;
const _readyForPlanSessions = 8;

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

final _userProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  return ref.watch(onboardingRepositoryProvider).getProfile(user.id);
});

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _readyForPlanChecked = false;

  PlanDayRow _suggestedDay(List<PlanDayRow> days) {
    final idx = DateTime.now().toUtc().millisecondsSinceEpoch ~/
            Duration(days: 1).inMilliseconds %
        days.length;
    return days[idx];
  }

  /// Show the ready-for-plan sheet once per session for observe-mode users
  /// who have no active plan and have hit the threshold (14 days OR 8 sessions).
  Future<void> _maybeShowReadyForPlan() async {
    if (_readyForPlanChecked) return;
    _readyForPlanChecked = true;

    final profile = ref.read(_userProfileProvider).asData?.value;
    if (profile == null) return;
    if (profile['onboarding_mode'] != 'observe') return;

    // Already has an active plan — nothing to prompt.
    final plan = ref.read(_activePlanProvider).asData?.value;
    if (plan != null) return;

    final userId = profile['id'] as String;
    final repo = ref.read(onboardingRepositoryProvider);
    final (days, sessions) = await (
      repo.daysSinceSignup(userId),
      repo.loggedSessionCount(userId),
    ).wait;
    if (days < _readyForPlanDays && sessions < _readyForPlanSessions) return;

    if (!mounted) return;
    unawaited(showModalBottomSheet<void>(
      context: context,
      builder: (_) => const ReadyForPlanSheet(),
    ));
  }

  Future<void> _freeTrain() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final sessionId = await ref.read(sessionRepoProvider).startSession(
          userId: userId,
          exerciseIds: const [],
        );
    if (mounted) unawaited(context.push('/session/$sessionId'));
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(_activePlanProvider);
    final profileAsync = ref.watch(_userProfileProvider);

    // Trigger ready-for-plan check once both plan and profile have loaded.
    if (planAsync.hasValue && profileAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_maybeShowReadyForPlan());
      });
    }

    final isGuided = profileAsync.asData?.value?['onboarding_mode'] == 'guided';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train'),
        actions: [
          const Padding(padding: EdgeInsets.all(8), child: SyncStatusPill()),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
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
                  if (isGuided) ...[
                    const SizedBox(height: _gap * 2),
                    TextButton.icon(
                      icon: const Icon(Icons.skip_next_outlined),
                      label: const Text('Free train today'),
                      onPressed: () => unawaited(_freeTrain()),
                    ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No active plan.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _gap / 2),
            Text(
              'Generate one and start training today.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _gap * 2),
            FilledButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate plan'),
              onPressed: () => context.push('/onboarding/guided'),
            ),
          ],
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
