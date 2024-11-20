import 'package:backend/core/database/db.dart';
import 'package:backend/core/database/tables/paints.drift.dart';
import 'package:backend/modules/paint/dtos/change.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@singleton
final class PaintService {
  PaintService(this.db);

  @protected
  final AppDatabase db;

  Future<List<Paint>> getAll() async {
    return db.paintDao.getAll();
  }

  Future<Paint> createOrUpdate(
    ChangeRequest data,
  ) async {
    final existingPaint = await db.paintDao.getPaintFromXY(data.x, data.y);
    if (existingPaint == null) {
      return await db.paintDao.insertFromChangeRequest(data);
    }
    return await db.paintDao.updateFromChangeRequest(data);
  }
}
