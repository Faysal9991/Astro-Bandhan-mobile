import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dio/Constant.dart';
import '../dio/dio_client.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

// Bloc
class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    on<SubmitPhoneNumber>((event, emit) async {

      // emit(ForgetPasswordLoading());

      try {
        final response = await _sendPhoneNumberToApi(event.phoneNumber);

        if (response.statusCode == 200) {

          final verificationId = response.data['data']['data']['verificationId'];

          final mobileNumber = response.data['data']['data']['mobileNumber'];


          emit(ForgetPasswordSuccess(verificationId: verificationId,mobileNumber:mobileNumber));

        } else {
          emit(ForgetPasswordFailure("Failed to send OTP. Please try again.x"));
        }
      } catch (e) {
        emit(ForgetPasswordFailure("An error occurred: ${e.toString()}"));
      }
    });
  }


  // Function to call the API using Dio
  // API Call using Dio
  Future<Response> _sendPhoneNumberToApi(String phoneNumber) async {

    final Dio dio = DioClient.instance.getDio();

    try {
      final apiUrl = '${base_upi}send/otp';

      print(apiUrl);

      final response = await dio.post(
        apiUrl,
        data: {'phone': phoneNumber,'role':'user'},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      print(response.data);
      return response;

    } catch (e) {
      throw Exception("Failed to call API: ${e.toString()}");
    }
  }
}
