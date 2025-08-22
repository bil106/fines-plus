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
