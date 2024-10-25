import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(useConstantCase: true)
class Env {
  @EnviedField()
  static const int port = _Env.port;

  @EnviedField()
  static const String token = _Env.token;

  @EnviedField()
  static const String databaseUrl = _Env.databaseUrl;
}
