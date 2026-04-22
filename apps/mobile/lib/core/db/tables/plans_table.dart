import 'package:drift/drift.dart';

@DataClassName('PlanRow')
class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get goal => text()();
  TextColumn get packId => text().nullable()();
  TextColumn get splitType => text()();
  IntColumn get daysPerWeek => integer()();
  BoolColumn get generatedByAi => boolean().withDefault(const Constant(false))();
  TextColumn get aiReasoning => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
