// forget_password_event.dart
import 'package:equatable/equatable.dart';

abstract class ForgetPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPhoneNumber extends ForgetPasswordEvent {

  final String phoneNumber;

  SubmitPhoneNumber(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}
