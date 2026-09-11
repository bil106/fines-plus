abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportActionSuccess extends SupportState {}

class SupportActionFailure extends SupportState {
  final String message;

  SupportActionFailure(this.message);
}
