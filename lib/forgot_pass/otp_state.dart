import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {

  const OtpState();

  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpSubmitting extends OtpState {}

class OtpSuccess extends OtpState {}

class OtpFailure extends OtpState {
  final String error;

  const OtpFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// class PasswordResetSubmitting extends OtpState {}

class PasswordResetSuccess extends OtpState {}

class OtpShowPasswordFields extends OtpState {}



class PasswordResetFailure extends OtpState {
  final String error;

  PasswordResetFailure(this.error);

  @override
  List<Object> get props => [error];
}
