import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(useConstantCase: true)
abstract final class Env {
  @EnviedField()
  static const String apiUrl = _Env.apiUrl;
}
