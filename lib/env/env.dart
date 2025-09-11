class Env {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.fines_plus.dev');

  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  static const openDataBotApiKey = String.fromEnvironment('OPEN_DATABOT_API_KEY', defaultValue: '');
  static const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY', defaultValue: '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI');
  static const mapApiKey = String.fromEnvironment('MAP_API_KEY', defaultValue: 'AIzaSyD8El-2EaU3iDuHLre3_Mz218iU-l1sr48');
}
