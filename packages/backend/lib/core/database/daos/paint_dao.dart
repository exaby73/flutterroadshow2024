import 'package:backend/core/database/daos/paint_dao.drift.dart';
import 'package:backend/core/database/db.dart';
import 'package:backend/core/database/tables/paints.dart';
import 'package:backend/core/database/tables/paints.drift.dart';
import 'package:backend/modules/paint/dtos/change.dart';
import 'package:drift/drift.dart';

@DriftAccessor(tables: [Paints])
class PaintDao extends DatabaseAccessor<AppDatabase> with $PaintDaoMixin {
  PaintDao(super.attachedDatabase);

  Future<List<Paint>> getAll() async {
    return await db.paints.select().get();
  }

  Future<Paint?> getPaintFromXY(int x, int y) async {
    final getStatement = db.paints.select()
      ..where((tbl) => tbl.x.equals(x) & tbl.y.equals(y));
    return await getStatement.getSingleOrNull();
  }

  Future<Paint> insertFromChangeRequest(ChangeRequest data) async {
    return await db.paints.insertReturning(
      PaintsCompanion.insert(
        x: data.x,
        y: data.y,
        r: data.color.r,
        g: data.color.g,
        b: data.color.b,
      ),
    );
  }

  Future<Paint> updateFromChangeRequest(ChangeRequest data) async {
    final updateStatement = db.paints.update()
      ..where((tbl) => tbl.x.equals(data.x) & tbl.y.equals(data.y));
    final updated = await updateStatement.writeReturning(
      PaintsCompanion.insert(
        x: data.x,
        y: data.y,
        r: data.color.r,
        g: data.color.g,
        b: data.color.b,
      ),
    );
    return updated.single;
  }
}
