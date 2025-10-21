class Env {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.fines_plus.dev');

  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  static const openDataBotApiKey = String.fromEnvironment('OPEN_DATABOT_API_KEY', defaultValue: '');

  static const recaptchaSiteKey = String.fromEnvironment(
    'RECAPTCHA_SITE_KEY',
    defaultValue: '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI',
  );

  static const mapApiKey = String.fromEnvironment(
    'MAP_API_KEY',
    defaultValue: 'AIzaSyD8El-2EaU3iDuHLre3_Mz218iU-l1sr48',
  );

  static const expId = String.fromEnvironment('EXP_ID', defaultValue: '61629');

  static const userid = String.fromEnvironment('USER_ID', defaultValue: '57addcc69a9d31050958cf509fa50f27');

  static const cfClearance = String.fromEnvironment(
    'CF_CLEARANCE',
    defaultValue:
        'eSpK4sIOdUWf79RU8Vr2F0XIMNHWSBsJIMc70xUS24U-1758266955-1.2.1.1-sZMWcCsaKDHx10cpul.zkeJX3ap1BmNX188AVJkoQy5Fc5xLEVoxAJcjweGZIU4TE9PXli9Pnc5GSGe.uez30Y.I1D3_P2N7qMZ.w_qxEzkOdUkyfk6nSiTxux8QE2.ibxuJ3nKAI4bFAXg4hxENPzRw2gP0UeW5lOlhlNFm5PkOPLo6hr4Tz468hqdY4F3JKVgQUWf.dpL4wwutt5dUBDjwCt1QTFjxDZcgRhAjK7A',
  );


  static const edriveToken = String.fromEnvironment('EDRIVE_TOKEN', defaultValue: 'VxiABhCleh');

    static const bearerToken = String.fromEnvironment(
    'BEARER_TOKEN',
    defaultValue:
        'eyJhbGciOiJSUzI1NiIsImtpZCI6IjA1NTc3MjZmYWIxMjMxZmEyZGNjNTcyMWExMDgzZGE2ODBjNGE3M2YiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiSWdvciBCZWxvZGVkIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0pYa3dfeUZVQmdSZERVcVAtN3plTEdZVEFOUzhNLTQ5TzdnWlc4aUtNRzJpVXhsSjQ9czk2LWMiLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZWRyaXZlLXByb2R1Y3Rpb24iLCJhdWQiOiJlZHJpdmUtcHJvZHVjdGlvbiIsImF1dGhfdGltZSI6MTc1ODkwMTI5OSwidXNlcl9pZCI6IjRqUlJmVTNEdFJWeGlBQmhDbGVoOGo3OHhxdTEiLCJzdWIiOiI0alJSZlUzRHRSVnhpQUJoQ2xlaDhqNzh4cXUxIiwiaWF0IjoxNzU4OTAxMjk5LCJleHAiOjE3NTg5MDQ4OTksImVtYWlsIjoiaWcuYmVsb2RlZEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjEwODU4NjczMDU0MjEzMjc1NjMyNyJdLCJlbWFpbCI6WyJpZy5iZWxvZGVkQGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0.cdI34LBWyd6CBIuJRyCIxkUmsjIfmpnJYPoa4QRuN2neb-NdhGRYucsfb5IP_j1qEpDHpRdSrk4yuk5hpOA4C5kTZwIx8GaeYpGTiFYIO8RvigyyB65oPr_tJlEdHG9_ONhYzqQWgYwRkbmDxeJN2oIy57UzY39qe0DRdXCanD8UU3Oh88vT0YJ3uyX_fWlY6aOT1kaWb9w4JYqPXzNHwIek2m0mHk-ebrGOvsWheGCh-pdkf2SuDoF5tHJUhysyQHPReqBD6688kDBYvV_fX4ZS-3tFPiN4A4z0C5dFQLdpja5Dfq_vycbNhkM_WVCW2Sg4xC1ui4eKSigyTVqijQ',
  );
    static const edriveUrl = String.fromEnvironment('EDRIVE_URL', defaultValue: 'https://e-drive.com.ua/');
static const testDeviceIds = String.fromEnvironment(
    'TEST_DEVICE_IDS',
    defaultValue: '9707CD691D448709BB2141139D990DDB', 
  );
  static List<String> get testDeviceIdList =>
      testDeviceIds.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).toList();
}
