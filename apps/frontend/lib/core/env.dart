import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(useConstantCase: true, interpolate: true)
class Env {
  const Env._();

  @EnviedField()
  static const String wsBaseUrl = _Env.wsBaseUrl;
}
