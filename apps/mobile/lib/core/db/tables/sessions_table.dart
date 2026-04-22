import 'package:drift/drift.dart';

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get planDayId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  RealColumn get bodyweight => real().nullable()();
  IntColumn get heartRateAvg => integer().nullable()();
  IntColumn get heartRateMax => integer().nullable()();
  IntColumn get caloriesEst => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
