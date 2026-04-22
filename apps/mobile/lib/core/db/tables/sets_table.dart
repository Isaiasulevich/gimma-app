import 'package:drift/drift.dart';

@DataClassName('SetRow')
class Sets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionExerciseId => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer()();
  IntColumn get rir => integer().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  TextColumn get tempo => text().nullable()();
  BoolColumn get isUnilateralLeft => boolean().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get loggedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
