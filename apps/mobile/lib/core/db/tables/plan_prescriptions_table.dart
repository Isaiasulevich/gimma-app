import 'package:drift/drift.dart';

@DataClassName('PlanPrescriptionRow')
class PlanPrescriptions extends Table {
  TextColumn get id => text()();
  TextColumn get planDayId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get order => integer()();
  IntColumn get targetSets => integer()();
  IntColumn get targetRepsMin => integer()();
  IntColumn get targetRepsMax => integer()();
  IntColumn get targetRir => integer()();
  IntColumn get targetRestSeconds => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
