/// Outcome of [RegistrationCubit.deleteAccount].
enum AccountDeletionResult {
  deleted,

  /// Firebase only deletes an account signed in within the last few
  /// minutes; the user has to sign in again first. Nothing was deleted.
  requiresRecentLogin,

  failed,
}
