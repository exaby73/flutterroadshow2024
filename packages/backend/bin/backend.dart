import 'dart:io';

import 'package:arcade/arcade.dart';
import 'package:backend/core/env.dart';
import 'package:backend/core/init.dart';

Future<void> main() async {
  late final int port;
  if (Env.port == null) {
    port = int.parse(Platform.environment['PORT']!);
  } else {
    port = Env.port!;
  }
  return runServer(port: port, init: init);
}
