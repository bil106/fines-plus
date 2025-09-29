import 'package:core_data/core_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokensRepositoryImpl implements TokensRepository {
  final FlutterSecureStorage storage;
  TokensRepositoryImpl(this.storage);

  static const _kEdriveToken = 'edriveToken';
  static const _kCsrf = 'csrf';
  static const _kCookie = 'cookie';
  static const _kFbUser = 'fbUser';

  @override
  Future<Tokens?> getSavedTokens() async {
    final token = await storage.read(key: _kEdriveToken);
    final csrf = await storage.read(key: _kCsrf);
    final cookie = await storage.read(key: _kCookie);
    final fbUser = await storage.read(key: _kFbUser);

    if (token != null && csrf != null) {
      return Tokens(
        edriveToken: token,
        csrf: csrf,
        cookie: cookie ?? '',
        fbUser: fbUser ?? '',
      );
    }
    return null;
  }

  @override
  Future<void> saveTokens(Tokens tokens) async {
    await storage.write(key: _kEdriveToken, value: tokens.edriveToken);
    await storage.write(key: _kCsrf, value: tokens.csrf);
    await storage.write(key: _kCookie, value: tokens.cookie);
    await storage.write(key: _kFbUser, value: tokens.fbUser);
  }
}
