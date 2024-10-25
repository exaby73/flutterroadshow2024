import 'package:drift/drift.dart';

class Paints extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get x => integer()();

  IntColumn get y => integer()();

  IntColumn get r => integer()();

  IntColumn get g => integer()();

  IntColumn get b => integer()();
}
