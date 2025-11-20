
import 'enum.dart';

class ApiConfig {
  static const String devUrl = 'https://thenexstore.codenexdev.com/api/v2/';
  static const String prodUrl = 'https://thenexstore.codenexdev.com/api/v2/';

  static late final Environment _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return devUrl;
      case Environment.prod:
        return prodUrl;
    }
  }
}
