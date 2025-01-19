// Login States
import 'package:astrologerapp/dio/Constant.dart';
import 'package:astrologerapp/dio/dio_client.dart';
import 'package:astrologerapp/model/user_details_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];

  UserState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

UserInfoModel userInfoModel = UserInfoModel();

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  Future<void> userinfo() async {
    final Dio dio = DioClient.instance.getDio();
      final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(isLoading: true));
    try {
      try {
        final url =
            '${Base_url}astrobandhan/v1/astrologer/profile/${prefs.getString("astrologer_id")}';
        print(url);

        

        final response = await dio.get(url);

        final responseData = response.data;

        if (response.statusCode == 200) {
          userInfoModel = UserInfoModel.fromJson(responseData["astrologer"]);
            emit(state.copyWith(isLoading: false, isSuccess: true));
          
        } else {
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
