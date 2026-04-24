import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/coach_api.dart';

final _coachApiProvider = Provider<CoachApi>((ref) => CoachApi(Supabase.instance.client));

final _latestSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return ref.watch(_coachApiProvider).latestWeeklySummary(userId);
});

class CoachTab extends ConsumerStatefulWidget {
  const CoachTab({super.key});
  @override
  ConsumerState<CoachTab> createState() => _CoachTabState();
}

class _CoachTabState extends ConsumerState<CoachTab> {
  bool _running = false;
  String? _fresh;

  Future<void> _reviewNow() async {
    setState(() => _running = true);
    try {
      final md = await ref.read(_coachApiProvider).reviewNow();
      if (mounted) setState(() => _fresh = md);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_latestSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Coach')),
      body: async.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_fresh != null)
              _SummaryCard(title: 'Just now', body: _fresh!)
            else if (summary != null)
              _SummaryCard(
                title: 'Week of ${summary['week_start']}',
                body: summary['summary_md'] as String,
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No summary yet. Log some training — Monday I\'ll write one automatically.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (summary != null) ...[
              _MetricsSection(summary: summary),
              const SizedBox(height: 24),
            ],
            FilledButton.icon(
              icon: const Icon(Icons.psychology),
              label: Text(_running ? 'Thinking…' : 'Review now'),
              onPressed: _running ? null : _reviewNow,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.summary});
  final Map<String, dynamic> summary;
  @override
  Widget build(BuildContext context) {
    final volume = (summary['volume_by_muscle'] as Map<String, dynamic>? ?? const {});
    final prs = (summary['prs'] as List<dynamic>? ?? const []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volume by muscle (sets)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        if (volume.isEmpty)
          const Text('—')
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: volume.entries.map((e) => Chip(label: Text('${e.key}: ${e.value}'))).toList(),
          ),
        const SizedBox(height: 16),
        Text('PRs', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        if (prs.isEmpty)
          const Text('No new PRs this week.')
        else
          ...prs.map((p) {
            final m = p as Map<String, dynamic>;
            return Text('${m['exercise_name']} — ${m['weight']}kg × ${m['reps']}');
          }),
      ],
    );
  }
}
