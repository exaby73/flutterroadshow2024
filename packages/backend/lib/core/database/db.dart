import 'package:backend/core/database/daos/paint_dao.dart';
import 'package:backend/core/database/db.drift.dart';
import 'package:backend/core/database/tables/paints.dart';
import 'package:backend/core/env.dart';
import 'package:drift/drift.dart';
import 'package:drift_hrana/drift_hrana.dart';
import 'package:injectable/injectable.dart';

@singleton
@DriftDatabase(
  tables: [Paints],
  daos: [PaintDao],
)
class AppDatabase extends $AppDatabase {
  AppDatabase() : super(_connection);

  @override
  int get schemaVersion => 1;

  static HranaDatabase get _connection {
    return HranaDatabase(
      Uri.parse(Env.databaseUrl),
      jwtToken: Env.token,
    );
  }
}
