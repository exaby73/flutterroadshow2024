import 'dart:async';
import 'dart:convert';

import 'package:arcade/arcade.dart';
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
    manager.emit(jsonEncode(AllResponse(data: await paintService.getAll())));
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
