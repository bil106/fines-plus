class Env {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.fines_plus.dev');

  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  static const openDataBotApiKey = String.fromEnvironment('OPEN_DATABOT_API_KEY', defaultValue: '');
  static const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY', defaultValue: '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI');
  static const mapApiKey = String.fromEnvironment('MAP_API_KEY', defaultValue: 'AIzaSyD8El-2EaU3iDuHLre3_Mz218iU-l1sr48');
  static const expId = String.fromEnvironment('EXP_ID', defaultValue: '61629');
  static const userid = String.fromEnvironment('USER_ID', defaultValue: '57addcc69a9d31050958cf509fa50f27');
  static const cfClearance = String.fromEnvironment('CF_CLEARANCE', defaultValue: 'eSpK4sIOdUWf79RU8Vr2F0XIMNHWSBsJIMc70xUS24U-1758266955-1.2.1.1-sZMWcCsaKDHx10cpul.zkeJX3ap1BmNX188AVJkoQy5Fc5xLEVoxAJcjweGZIU4TE9PXli9Pnc5GSGe.uez30Y.I1D3_P2N7qMZ.w_qxEzkOdUkyfk6nSiTxux8QE2.ibxuJ3nKAI4bFAXg4hxENPzRw2gP0UeW5lOlhlNFm5PkOPLo6hr4Tz468hqdY4F3JKVgQUWf.dpL4wwutt5dUBDjwCt1QTFjxDZcgRhAjK7A');
}
