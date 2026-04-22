enum SyncPhase { idle, syncing, offline, error }

class SyncState {
  const SyncState({
    required this.phase,
    required this.pendingCount,
    this.lastError,
    this.lastSyncedAt,
  });

  final SyncPhase phase;
  final int pendingCount;
  final String? lastError;
  final DateTime? lastSyncedAt;

  SyncState copyWith({
    SyncPhase? phase,
    int? pendingCount,
    String? lastError,
    DateTime? lastSyncedAt,
  }) =>
      SyncState(
        phase: phase ?? this.phase,
        pendingCount: pendingCount ?? this.pendingCount,
        lastError: lastError,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );

  static const idle = SyncState(phase: SyncPhase.idle, pendingCount: 0);
}
