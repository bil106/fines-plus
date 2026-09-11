import 'package:equatable/equatable.dart';

class RegistrationState extends Equatable {
  final bool isLoading;
  final bool isExistingUser;
  final String? emailError;
  final String? error;
  final bool isRegistered;
  final bool isDeleted;

  const RegistrationState({
    this.isLoading = false,
    this.isExistingUser = false,
    this.emailError,
    this.error,
    this.isRegistered = false,
    this.isDeleted = false,
  });

  RegistrationState copyWith({
    bool? isLoading,
    bool? isExistingUser,
    String? emailError,
    String? error,
    bool? isRegistered,
    bool? isDeleted,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      isExistingUser: isExistingUser ?? this.isExistingUser,
      emailError: emailError,
      error: error,
      isRegistered: isRegistered ?? this.isRegistered,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [isLoading, isExistingUser, emailError, error, isRegistered, isDeleted];
}
