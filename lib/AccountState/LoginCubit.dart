import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dio/Constant.dart';
import '../dio/dio_client.dart';

// Login States
class LoginState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Login Cubit
class LoginCubit extends Cubit<LoginState> {

  LoginCubit() : super(const LoginState());

  Future<void> login(String phone, String password) async {

    final Dio dio = DioClient.instance.getDio();

    emit(state.copyWith(isLoading: true));
    try {

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      try {
        final url = '${base_upi1}login';
        print(url);

        final Map<String, dynamic> data = {
          "phone":phone,
          "password":password
        };

        print(data);

        emit(state.copyWith(isSuccess: null));

        final response = await dio.post(url, data: data);

        final responseData = response.data;

        if (response.statusCode == 200) {

          final accessToken = responseData['accessToken'];
          final refreshToken = responseData['refreshToken'];

          final astrologer_id = responseData['astrologer']["id"];
          final astrologer_name = responseData['astrologer']["name"];
          final astrologer_phone = responseData['astrologer']["phone"];
          final astrologer_available = responseData['astrologer']["available"]["isAvailable"];

          final message = responseData['message'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', refreshToken);

          await prefs.setString('astrologer_id', astrologer_id);
          await prefs.setString('astrologer_name', astrologer_name);
          await prefs.setString('astrologer_phone', astrologer_phone);
          await prefs.setBool('astrologer_available', astrologer_available);

          emit(state.copyWith(errorMessage: message));
          emit(state.copyWith(isLoading: false, isSuccess: true));

        }else{

          final message = responseData['message'];

          emit(state.copyWith(isLoading: false, isSuccess: false));
          emit(state.copyWith(errorMessage: message));

        }

      } catch (error) {

        print('Error: $error');

        emit(state.copyWith(isSuccess: null));

        if (error is DioException) {

          print('Error status code: ${error.response?.statusCode}');
          print('Error message: ${error.response?.data}');
          emit(state.copyWith(isLoading: false, isSuccess: false));
        }
      }

      // Example: Successful Login

    } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}






