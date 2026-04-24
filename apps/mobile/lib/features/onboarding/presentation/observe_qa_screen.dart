import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/onboarding_state_provider.dart';

const _gap = 16.0;

class ObserveQaScreen extends ConsumerStatefulWidget {
  const ObserveQaScreen({super.key});

  @override
  ConsumerState<ObserveQaScreen> createState() => _ObserveQaScreenState();
}

class _ObserveQaScreenState extends ConsumerState<ObserveQaScreen> {
  String _goal = 'muscle';
  int _daysPerWeek = 4;
  String _equipment = 'full gym';

  Future<void> _finish() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.setMode(userId: userId, mode: 'observe', goal: _goal);
    await repo.markComplete(userId);
    ref.invalidate(onboardingCompleteProvider);
    if (mounted) context.go('/train');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observation mode')),
      body: ListView(
        padding: const EdgeInsets.all(_gap),
        children: [
          Text(
            'Log your training for ~2 weeks. Once I\'ve seen enough, I\'ll propose a plan that respects what you\'ve been doing.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: _gap * 1.5),
          Text(
            'Goal',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          DropdownButton<String>(
            value: _goal,
            items: const [
              DropdownMenuItem(value: 'muscle', child: Text('Muscle')),
              DropdownMenuItem(value: 'strength', child: Text('Strength')),
              DropdownMenuItem(value: 'fat_loss', child: Text('Fat loss')),
              DropdownMenuItem(value: 'general', child: Text('General')),
            ],
            onChanged: (v) => setState(() => _goal = v!),
          ),
          const SizedBox(height: _gap),
          Text(
            'Training days / week',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: _daysPerWeek.toDouble(),
            min: 2,
            max: 6,
            divisions: 4,
            label: '$_daysPerWeek',
            onChanged: (v) => setState(() => _daysPerWeek = v.round()),
          ),
          const SizedBox(height: _gap),
          Text(
            'Equipment',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          DropdownButton<String>(
            value: _equipment,
            items: const [
              DropdownMenuItem(value: 'full gym', child: Text('Full gym')),
              DropdownMenuItem(
                value: 'home + dumbbells',
                child: Text('Home + dumbbells'),
              ),
              DropdownMenuItem(value: 'bodyweight', child: Text('Bodyweight')),
            ],
            onChanged: (v) => setState(() => _equipment = v!),
          ),
          const SizedBox(height: _gap * 2),
          FilledButton(
            onPressed: () => unawaited(_finish()),
            child: const Text('Start free-logging'),
          ),
        ],
      ),
    );
  }
}
