import 'package:drift/drift.dart';

@DataClassName('PlanDayRow')
class PlanDays extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  IntColumn get dayNumber => integer()();
  TextColumn get name => text()();
  TextColumn get focus => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
