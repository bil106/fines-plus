class Env {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.fines_plus.dev');

  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  static const openDataBotApiKey = String.fromEnvironment('OPEN_DATABOT_API_KEY', defaultValue: '');
}
