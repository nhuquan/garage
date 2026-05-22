

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';


part 'app_database.g.dart';

class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get year => integer()();
  RealColumn get currentKm => real()();
  TextColumn get description => text().withDefault(const Constant('value'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MaintenanceItems extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles,#id)();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get kmAtService => real()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

}

@DriftDatabase(tables: [Vehicles, MaintenanceItems])
class AppDatabase extends _$AppDatabase{
  AppDatabase() : super (_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'garage.db'));
      return NativeDatabase(file);
    });
  }

}

