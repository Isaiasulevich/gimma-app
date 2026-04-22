import 'package:drift/drift.dart';

@DataClassName('SessionExerciseRow')
class SessionExercises extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get order => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get skipReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
