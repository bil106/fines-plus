import 'package:equatable/equatable.dart';

abstract class AdditionalOptionsState extends Equatable {
  const AdditionalOptionsState();
  @override
  List<Object?> get props => [];
}

class AdditionalOptionsInitial extends AdditionalOptionsState {}

class AdditionalOptionsLoading extends AdditionalOptionsState {}

class AdditionalOptionsTokensPresent extends AdditionalOptionsState {}

class AdditionalOptionsTokensMissing extends AdditionalOptionsState {}

class AdditionalOptionsExtracted extends AdditionalOptionsState {}

class AdditionalOptionsError extends AdditionalOptionsState {
  final String message;
  const AdditionalOptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
