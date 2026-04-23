import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/progression_service.dart';
import 'rest_timer.dart';
import 'session_controller.dart';
import 'today_screen.dart' show sessionRepoProvider;
import 'widgets/set_row_view.dart';

const _gap = 12.0;

final progressionProvider = Provider<ProgressionService>(
  (ref) => ProgressionService(ref.watch(appDatabaseProvider)),
);

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({required this.sessionId, super.key});
  final String sessionId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  double? _weight;
  int? _reps;
  int? _rir;
  bool _resting = false;
  int _restSeconds = 120;
  String? _prefilledFor; // id of session_exercise we prefilled for

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _prefill(SessionExerciseRow current, int targetRest) async {
    if (_prefilledFor == current.id) return;
    final last = await ref.read(progressionProvider).lastSetFor(current.exerciseId);
    if (!mounted) return;
    setState(() {
      _prefilledFor = current.id;
      _weight = last?.weight;
      _reps = last?.reps;
      _rir = last?.rir;
      _restSeconds = targetRest;
    });
  }

  Future<void> _logSet({
    required String sessionExerciseId,
    required int setNumber,
  }) async {
    await ref.read(sessionRepoProvider).logSet(
          sessionExerciseId: sessionExerciseId,
          setNumber: setNumber,
          weight: _weight,
          reps: _reps ?? 0,
          rir: _rir,
          restSeconds: _restSeconds,
        );
    if (!mounted) return;
    setState(() => _resting = true);
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(currentExerciseProvider(widget.sessionId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
        actions: [
          TextButton(
            onPressed: () => context.push('/session/${widget.sessionId}/finish'),
            child: const Text('Finish'),
          ),
        ],
      ),
      body: current == null
          ? _AllDoneBanner(sessionId: widget.sessionId)
          : _ExerciseView(
              sessionExercise: current,
              resting: _resting,
              restSeconds: _restSeconds,
              weight: _weight,
              reps: _reps,
              rir: _rir,
              onChangeWeight: (v) => setState(() => _weight = v),
              onChangeReps: (v) => setState(() => _reps = v),
              onChangeRir: (v) => setState(() => _rir = v),
              onLog: (setNumber) =>
                  unawaited(_logSet(sessionExerciseId: current.id, setNumber: setNumber)),
              onRestDone: () => setState(() => _resting = false),
              onPrefillIfEmpty: () => unawaited(_prefill(current, _restSeconds)),
            ),
    );
  }
}

class _AllDoneBanner extends ConsumerWidget {
  const _AllDoneBanner({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skipped = ref.watch(skippedExercisesProvider(sessionId));
    if (skipped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'All exercises complete. Tap Finish to wrap up.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return _SkippedRePrompt(sessionId: sessionId, skipped: skipped);
  }
}

class _SkippedRePrompt extends ConsumerWidget {
  const _SkippedRePrompt({required this.sessionId, required this.skipped});

  final String sessionId;
  final List<SessionExerciseRow> skipped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'You skipped ${skipped.length} exercise${skipped.length == 1 ? '' : 's'}.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: _gap),
        Text(
          'Want to try any of them now?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: _gap * 2),
        for (final se in skipped)
          Padding(
            padding: const EdgeInsets.only(bottom: _gap),
            child: Card(
              child: ListTile(
                title: Text('Exercise #${se.order}'),
                subtitle: Text(se.skipReason ?? ''),
                trailing: FilledButton(
                  onPressed: () => unawaited(
                    ref.read(sessionRepoProvider).resumeExercise(se.id),
                  ),
                  child: const Text('Do now'),
                ),
              ),
            ),
          ),
        const SizedBox(height: _gap),
        OutlinedButton(
          onPressed: () =>
              unawaited(context.push('/session/$sessionId/finish')),
          child: const Text('Finish anyway'),
        ),
      ],
    );
  }
}

class _ExerciseView extends ConsumerWidget {
  const _ExerciseView({
    required this.sessionExercise,
    required this.resting,
    required this.restSeconds,
    required this.weight,
    required this.reps,
    required this.rir,
    required this.onChangeWeight,
    required this.onChangeReps,
    required this.onChangeRir,
    required this.onLog,
    required this.onRestDone,
    required this.onPrefillIfEmpty,
  });

  final SessionExerciseRow sessionExercise;
  final bool resting;
  final int restSeconds;
  final double? weight;
  final int? reps;
  final int? rir;
  final ValueChanged<double> onChangeWeight;
  final ValueChanged<int> onChangeReps;
  final ValueChanged<int> onChangeRir;
  final void Function(int setNumber) onLog;
  final VoidCallback onRestDone;
  final VoidCallback onPrefillIfEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(setsStreamProvider(sessionExercise.id));
    return setsAsync.when(
      data: (sets) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (sets.isEmpty) onPrefillIfEmpty();
        });
        final nextSet = sets.length + 1;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Exercise ${sessionExercise.order}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: _gap),
            _NumberInputs(
              weight: weight,
              reps: reps,
              rir: rir,
              onChangeWeight: onChangeWeight,
              onChangeReps: onChangeReps,
              onChangeRir: onChangeRir,
            ),
            const SizedBox(height: _gap),
            if (resting)
              RestTimer(
                durationSeconds: restSeconds,
                onFinished: onRestDone,
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => onLog(nextSet),
                  child: Text('Log set $nextSet · start rest'),
                ),
              ),
            const SizedBox(height: _gap * 2),
            const SetHeader(),
            for (final entry in sets.asMap().entries)
              SetRowView(index: entry.key + 1, set: entry.value),
            SetRowView(
              index: nextSet,
              isActive: !resting,
              targetWeight: weight,
              targetReps: reps,
              targetRir: rir,
            ),
            const SizedBox(height: _gap * 2),
            OutlinedButton.icon(
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip (machine busy)'),
              onPressed: () => unawaited(
                ref
                    .read(sessionRepoProvider)
                    .skipExercise(sessionExercise.id, reason: 'machine busy'),
              ),
            ),
            const SizedBox(height: _gap / 2),
            OutlinedButton.icon(
              icon: const Icon(Icons.done_all),
              label: const Text('Done with this exercise'),
              onPressed: () => unawaited(
                ref
                    .read(sessionRepoProvider)
                    .markExerciseDone(sessionExercise.id),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _NumberInputs extends StatelessWidget {
  const _NumberInputs({
    required this.weight,
    required this.reps,
    required this.rir,
    required this.onChangeWeight,
    required this.onChangeReps,
    required this.onChangeRir,
  });

  final double? weight;
  final int? reps;
  final int? rir;
  final ValueChanged<double> onChangeWeight;
  final ValueChanged<int> onChangeReps;
  final ValueChanged<int> onChangeRir;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NumberField(
            label: 'Weight',
            value: weight?.toStringAsFixed(1) ?? '',
            decimal: true,
            onParsed: (s) {
              final d = double.tryParse(s);
              if (d != null) onChangeWeight(d);
            },
          ),
        ),
        const SizedBox(width: _gap / 1.5),
        Expanded(
          child: _NumberField(
            label: 'Reps',
            value: reps?.toString() ?? '',
            decimal: false,
            onParsed: (s) {
              final i = int.tryParse(s);
              if (i != null) onChangeReps(i);
            },
          ),
        ),
        const SizedBox(width: _gap / 1.5),
        Expanded(
          child: _NumberField(
            label: 'RIR',
            value: rir?.toString() ?? '',
            decimal: false,
            onParsed: (s) {
              final i = int.tryParse(s);
              if (i != null) onChangeRir(i);
            },
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.decimal,
    required this.onParsed,
  });

  final String label;
  final String value;
  final bool decimal;
  final ValueChanged<String> onParsed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(labelText: label),
      onChanged: onParsed,
    );
  }
}
