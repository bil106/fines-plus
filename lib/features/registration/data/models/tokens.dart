class Tokens {
  final String edriveToken;
  final String csrf;
  final String cookie;
  final String fbUser;

  const Tokens({
    required this.edriveToken,
    required this.csrf,
    required this.cookie,
    required this.fbUser,
  });
}

abstract interface class TokensRepository {
  Future<Tokens?> getSavedTokens();
  Future<void> saveTokens(Tokens tokens);
}
