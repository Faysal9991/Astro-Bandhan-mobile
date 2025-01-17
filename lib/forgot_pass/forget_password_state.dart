// forget_password_state.dart
import 'package:equatable/equatable.dart';

abstract class ForgetPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordLoading extends ForgetPasswordState {}

class ForgetPasswordSuccess extends ForgetPasswordState {
  final String verificationId;
  final String mobileNumber;

  ForgetPasswordSuccess({required this.verificationId,required this.mobileNumber});
}

class ForgetPasswordFailure extends ForgetPasswordState {
  final String error;

  ForgetPasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
