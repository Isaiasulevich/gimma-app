import 'package:drift/drift.dart';

import '../converters.dart';

@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUserId => text().nullable()();
  TextColumn get source => text()(); // 'seed' | 'user'
  TextColumn get sourceRef => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get localPhotoPath => text().nullable()(); // queued upload
  TextColumn get primaryMuscle => text()();
  TextColumn get secondaryMuscles => text().map(const StringListConverter())();
  TextColumn get equipment => text()();
  BoolColumn get isUnilateral => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
