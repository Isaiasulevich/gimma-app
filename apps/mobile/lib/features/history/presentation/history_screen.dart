import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../data/history_repository.dart';

const _gap = 12.0;

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(appDatabaseProvider)),
);

final _completedSessionsProvider =
    StreamProvider.autoDispose<List<SessionRow>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(historyRepositoryProvider).watchCompleted(userId);
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_completedSessionsProvider);
    return async.when(
      data: (rows) {
        if (rows.isEmpty) return const _EmptyState();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (_, i) => _SessionTile(session: rows[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
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
            Icon(
              Icons.fitness_center,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: _gap),
            Text(
              'No completed sessions yet.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _gap / 2),
            Text(
              'Finish a workout and it shows up here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});
  final SessionRow session;

  String _formatDate(DateTime utc) {
    final local = utc.toLocal();
    final m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][local.month - 1];
    return '$m ${local.day}';
  }

  String _duration() {
    final end = session.endedAt;
    if (end == null) return '';
    final mins = end.difference(session.startedAt).inMinutes;
    return '· $mins min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(historyRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Card(
        child: FutureBuilder<int>(
          future: repo.totalSetsFor(session.id),
          builder: (context, snap) {
            final sets = snap.data ?? 0;
            return ListTile(
              title: Text(_formatDate(session.startedAt)),
              subtitle: Text('$sets sets ${_duration()}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/history/${session.id}'),
            );
          },
        ),
      ),
    );
  }
}
