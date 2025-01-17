import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {

  const OtpEvent();

  @override
  List<Object?> get props => [];
}

class OtpEntered extends OtpEvent {
  final String otp;
  final String verificationId;
  final String mobileNumber;

  const OtpEntered(this.otp, this.verificationId,this.mobileNumber);

  @override
  List<Object?> get props => [otp, verificationId, mobileNumber];
}

class OtpResendRequested extends OtpEvent {}

class OtpShowPasswordFieldsEvent extends OtpEvent {}

class PasswordSubmitEvent extends OtpEvent {
  final String mobileNumber;
  final String password;
  final String confirmPassword;

  PasswordSubmitEvent(this.mobileNumber, this.password, this.confirmPassword);


  @override
  List<Object?> get props => [mobileNumber, password, confirmPassword];
}
