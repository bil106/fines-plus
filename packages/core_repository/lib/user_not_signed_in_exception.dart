class UserNotSignedInException implements Exception {
  final String message;
  UserNotSignedInException([this.message = 'User is not signed in']);

  @override
  String toString() => message;
}
