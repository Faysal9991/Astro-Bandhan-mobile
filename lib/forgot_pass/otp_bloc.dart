import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_event.dart';
import 'otp_state.dart';
import '../dio/dio_client.dart';
import '../dio/Constant.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc() : super(OtpInitial()) {
    // Register handlers for events
    on<OtpEntered>(_onOtpEntered);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpShowPasswordFieldsEvent>(_onOtpShowPasswordFieldsEvent);
    on<PasswordSubmitEvent>(_onPasswordSubmitEvent); // Make sure to register this event
  }

  Future<void> _onOtpEntered(OtpEntered event, Emitter<OtpState> emit) async {
    emit(OtpSubmitting());
    try {
      final Dio dio = DioClient.instance.getDio();
      final apiUrl = '${base_upi}validate/otp';
      print('API URL: $apiUrl');

      final Map<String, dynamic> data = {
        "verificationId": event.verificationId,
        "code": event.otp,
        "phone": event.mobileNumber,
      };

      final response = await dio.post(apiUrl, data: data);

      if (response.statusCode == 200) {
        emit(OtpSuccess());
      } else {
        final String errorMessage = response.data?['message'] ?? 'Invalid OTP';
        emit(OtpFailure(errorMessage));
      }
    } on DioException catch (dioError) {
      emit(OtpFailure(dioError.response?.data?['message'] ?? 'An error occurred'));
    } catch (e) {
      emit(OtpFailure('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onOtpResendRequested(OtpResendRequested event, Emitter<OtpState> emit) async {
    await Future.delayed(const Duration(seconds: 1));
    emit(OtpInitial());
  }

  Future<void> _onOtpShowPasswordFieldsEvent(OtpShowPasswordFieldsEvent event, Emitter<OtpState> emit) async {
    emit(OtpShowPasswordFields());
  }

  Future<void> _onPasswordSubmitEvent(PasswordSubmitEvent event, Emitter<OtpState> emit) async {
    // emit(PasswordResetSubmitting());
    print("object");
    try {
      final Dio dio = DioClient.instance.getDio();
      final apiUrl = '${base_upi}update/password';
      print('API URL: $apiUrl');

      final Map<String, dynamic> data = {
        "newPassword": event.password,
        "phone": event.mobileNumber,
      };

      print(data);
      final response = await dio.post(apiUrl, data: data);
      print(apiUrl);


      print(response);
      if (response.statusCode == 200) {
        emit(PasswordResetSuccess());

      } else {
        final message = response.data?['message'] ?? 'Password reset failed';

        // emit(PasswordResetFailure(message));
      }
    } on DioException catch (dioError) {

      // emit(PasswordResetFailure(dioError.response?.data?['message'] ?? 'An error occurred'));
    } catch (e) {
      // emit(PasswordResetFailure('An unexpected error occurred: $e'));
    }
  }
}
