import 'package:drift/drift.dart';

/// Outbox of pending sync operations. Each row represents a local write
/// that needs to be pushed to the server. On success, the row is deleted.
@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  TextColumn get id => text()(); // UUID of the local row
  TextColumn get entityTable => text()(); // 'exercises', 'sessions', ...
  TextColumn get operation => text()(); // 'insert' | 'update' | 'delete'
  DateTimeColumn get queuedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id, entityTable};
}
