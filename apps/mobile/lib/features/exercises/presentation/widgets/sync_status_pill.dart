import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/supabase_sync_remote.dart';
import '../../../../core/sync/sync_status.dart';

final _syncStateProvider = StreamProvider<SyncState>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.state;
});

class SyncStatusPill extends ConsumerWidget {
  const SyncStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_syncStateProvider);
    final state = async.value ?? SyncState.idle;
    final (bg, fg, label) = switch (state.phase) {
      SyncPhase.idle when state.pendingCount == 0 =>
        (Colors.green.shade100, Colors.green.shade900, 'Synced'),
      SyncPhase.syncing =>
        (Colors.blue.shade100, Colors.blue.shade900, 'Syncing ${state.pendingCount}'),
      SyncPhase.offline => (Colors.grey.shade300, Colors.grey.shade800, 'Offline'),
      SyncPhase.error =>
        (Colors.orange.shade100, Colors.orange.shade900, '${state.pendingCount} pending'),
      _ => (Colors.grey.shade200, Colors.grey.shade800, 'Syncing'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
