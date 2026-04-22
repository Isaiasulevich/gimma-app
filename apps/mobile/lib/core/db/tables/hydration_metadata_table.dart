import 'package:drift/drift.dart';

@DataClassName('HydrationMetadataRow')
class HydrationMetadata extends Table {
  TextColumn get entityTable => text()();
  DateTimeColumn get lastPulledAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityTable};
}
