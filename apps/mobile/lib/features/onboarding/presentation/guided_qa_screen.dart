import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../plans/data/plan_api.dart';
import '../data/onboarding_state_provider.dart';

const _gap = 16.0;

class _Answers {
  String goal = 'muscle';
  String experience = 'intermediate';
  int daysPerWeek = 4;
  int sessionLength = 60;
  String equipment = 'full gym';
  List<String> injuries = [];
  String styleNotes = '';
}

class GuidedQaScreen extends ConsumerStatefulWidget {
  const GuidedQaScreen({super.key});

  @override
  ConsumerState<GuidedQaScreen> createState() => _GuidedQaScreenState();
}

class _GuidedQaScreenState extends ConsumerState<GuidedQaScreen> {
  int _step = 0;
  final _answers = _Answers();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  static const _last = 6;

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _RadioGroup(
          title: 'Goal',
          options: const [
            ('muscle', 'Muscle / hypertrophy'),
            ('strength', 'Strength'),
            ('fat_loss', 'Fat loss'),
            ('general', 'General fitness'),
          ],
          selected: _answers.goal,
          onChanged: (v) => setState(() => _answers.goal = v),
        );
      case 1:
        return _RadioGroup(
          title: 'Experience',
          options: const [
            ('beginner', 'Beginner (< 1 year)'),
            ('intermediate', 'Intermediate (1–3 years)'),
            ('advanced', 'Advanced (3+ years)'),
          ],
          selected: _answers.experience,
          onChanged: (v) => setState(() => _answers.experience = v),
        );
      case 2:
        return _IntSlider(
          title: 'Days per week',
          value: _answers.daysPerWeek,
          min: 2,
          max: 6,
          onChanged: (v) => setState(() => _answers.daysPerWeek = v),
        );
      case 3:
        return _IntSlider(
          title: 'Session length (minutes)',
          value: _answers.sessionLength,
          min: 30,
          max: 120,
          step: 15,
          onChanged: (v) => setState(() => _answers.sessionLength = v),
        );
      case 4:
        return _RadioGroup(
          title: 'Equipment',
          options: const [
            ('full gym', 'Full gym'),
            ('home + dumbbells', 'Home gym (dumbbells + bench)'),
            ('bodyweight', 'Bodyweight only'),
          ],
          selected: _answers.equipment,
          onChanged: (v) => setState(() => _answers.equipment = v),
        );
      case 5:
        return _MultiSelect(
          title: 'Injuries / limitations',
          options: const [
            ('knee_pain', 'Knee'),
            ('lower_back_pain', 'Lower back'),
            ('shoulder_pain', 'Shoulder'),
            ('wrist', 'Wrist'),
          ],
          selected: _answers.injuries.toSet(),
          onChanged: (s) => setState(() => _answers.injuries = s.toList()),
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(_gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Style notes (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: _gap / 2),
              TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g. "I like high volume, hate cardio"',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _answers.styleNotes = v,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _finish() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.setMode(
      userId: userId,
      mode: 'guided',
      goal: _answers.goal,
      experienceLevel: _answers.experience,
    );
    if (!mounted) return;
    context.go('/onboarding/generating');

    final api = PlanApi(Supabase.instance.client);
    try {
      await api.generatePlan(
        goal: _answers.goal,
        experienceLevel: _answers.experience,
        daysPerWeek: _answers.daysPerWeek,
        sessionLengthMinutes: _answers.sessionLength,
        equipment: _answers.equipment,
        injuries: _answers.injuries,
        styleNotes: _answers.styleNotes.isEmpty ? null : _answers.styleNotes,
      );
      await repo.markComplete(userId);
      ref.invalidate(onboardingCompleteProvider);
      if (mounted) context.go('/train');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan generation failed: $e')),
      );
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Step ${_step + 1} of ${_last + 1}')),
      body: _stepBody(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_gap),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Back'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (_step < _last) {
                    setState(() => _step++);
                  } else {
                    unawaited(_finish());
                  }
                },
                child: Text(_step < _last ? 'Next' : 'Generate plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  const _RadioGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(_gap),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: _gap / 2),
        for (final o in options)
          RadioListTile<String>(
            title: Text(o.$2),
            value: o.$1,
            // ignore: deprecated_member_use
            groupValue: selected,
            // ignore: deprecated_member_use
            onChanged: (v) => onChanged(v!),
          ),
      ],
    );
  }
}

class _IntSlider extends StatelessWidget {
  const _IntSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: $value',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ step,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _MultiSelect extends StatelessWidget {
  const _MultiSelect({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<(String, String)> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(_gap),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: _gap / 2),
        for (final o in options)
          CheckboxListTile(
            title: Text(o.$2),
            value: selected.contains(o.$1),
            onChanged: (v) {
              final next = {...selected};
              if (v == true) {
                next.add(o.$1);
              } else {
                next.remove(o.$1);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
