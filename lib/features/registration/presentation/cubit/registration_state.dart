class RegistrationState {
  final bool isLoading;
  final bool isRegistered;
  final String? error;

  RegistrationState({
    this.isLoading = false,
    this.isRegistered = false,
    this.error,
  });

  RegistrationState copyWith({
    bool? isLoading,
    bool? isRegistered,
    String? error,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      isRegistered: isRegistered ?? this.isRegistered,
      error: error,
    );
  }
}
