
import 'package:core_data/core_data.dart';
import 'package:equatable/equatable.dart';



abstract class FinesState extends Equatable {
  const FinesState();

  @override
  List<Object?> get props => [];
}

class FinesInitial extends FinesState {}

class FinesLoading extends FinesState {}

class FinesLoaded extends FinesState {
  final List<Fine> fines;
  const FinesLoaded(this.fines);

  @override
  List<Object?> get props => [fines];
}

class FinesEmpty extends FinesState {}

class FinesError extends FinesState {
  final String message;
  const FinesError(this.message);

  @override
  List<Object?> get props => [message];
}
class FinesCaptcha extends FinesState {
  final String captchaUrl; 
  const FinesCaptcha(this.captchaUrl);

  @override
  List<Object?> get props => [captchaUrl];
}

class FinesLogLoaded extends FinesState {
  final List<String> logs;
  const FinesLogLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}
