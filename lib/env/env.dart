import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiUrl => dotenv.env['API_URL'] ?? 'https://api.fines_plus.dev';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get openDataBotApiKey => dotenv.env['OPEN_DATABOT_API_KEY'] ?? '';
  static String get recaptchaSiteKey => dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';
  static String get mapApiKey => dotenv.env['MAP_API_KEY'] ?? '';
  static String get expId => dotenv.env['EXP_ID'] ?? '61629';
  static String get userId => dotenv.env['USER_ID'] ?? '';
  static String get cfClearance => dotenv.env['CF_CLEARANCE'] ?? '';
  static String get edriveToken => dotenv.env['EDRIVE_TOKEN'] ?? '';
  static String get bearerToken => dotenv.env['BEARER_TOKEN'] ?? '';
  static String get edriveUrl => dotenv.env['EDRIVE_URL'] ?? '';
  static String get privacyPolicyUrl => dotenv.env['PRIVACY_POLICY_URL'] ?? '';
  static String get termsUrl => dotenv.env['TERMS_URL'] ?? '';
  static String get googlePlayUrl => 'https://play.google.com/store';

  static List<String> get testDeviceIdList {
    final ids = dotenv.env['TEST_DEVICE_IDS'] ?? '';
    return ids.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}
