import 'package:arcade/arcade.dart';
import 'package:backend/core/env.dart';
import 'package:backend/core/init.dart';

Future<void> main() async {
  return runServer(port: Env.port, init: init);
}
