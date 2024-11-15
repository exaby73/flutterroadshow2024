import 'dart:async';
import 'dart:convert';

import 'package:arcade/arcade.dart';
import 'package:backend/core/database/tables/paints.drift.dart';
import 'package:backend/modules/paint/dtos/change.dart';
import 'package:backend/modules/paint/services/paint_service.dart';
import 'package:injectable/injectable.dart';

@singleton
final class PaintController {
  PaintController(this.paintService) {
    route.get('/').handleWebSocket(wsHandler, onConnect: onConnect);
  }

  final PaintService paintService;

  FutureOr<void> onConnect(
    RequestContext context,
    WebSocketManager manager,
  ) async {
    final rawData = await paintService.getAll();
    final List<List<Paint?>> data = [];

    for (final paint in rawData) {
      while (data.length <= paint.y) {
        data.add([]);
      }
      while (data[paint.y].length <= paint.x) {
        data[paint.y].add(null);
      }
      data[paint.y][paint.x] = paint;
    }
    manager.emit(jsonEncode(AllResponse(data: data)));
  }

  FutureOr<void> wsHandler(
    RequestContext context,
    dynamic message,
    WebSocketManager manager,
  ) async {
    final data = $ChangeRequestValidate(
      jsonDecode(message as String) as Map<String, dynamic>,
    ).data;

    if (data == null) return;
    final paint = await paintService.createOrUpdate(data);
    emitToAll(jsonEncode(UpdateResponse(data: paint)));
  }
}
