import 'package:astrologerapp/Wallet/model/bank_details.dart';
import 'package:astrologerapp/dio/Constant.dart';
import 'package:astrologerapp/dio/dio_client.dart';
import 'package:astrologerapp/helper/navigator_helper.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WithdrawState extends Equatable {
  final bool isLoading;
  final bool isSuccess; // New boolean state
  final String? errorMessage;

  const WithdrawState({
    this.isLoading = false,
    this.isSuccess = false,
// Default value for the toggle
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];

  WithdrawState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return WithdrawState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Login Cubit
class WithdrawCubit extends Cubit<WithdrawState> {
  WithdrawCubit() : super(const WithdrawState());

  Future<void> withdrawRequest(
      {required int ammount,
      required String withdrawType,
      BankDetails? bankDetails,
      String? upi}) async {
    final Dio dio = DioClient.instance.getDio();

    emit(state.copyWith(isLoading: true));
    final prefs = await SharedPreferences.getInstance();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      final Map<String, dynamic> data = {
        "astrologerId": prefs.getString('astrologer_id'),
        "amount": ammount,
        "withdrawalType": withdrawType,
      };
      withdrawType == "Bank"
          ? data.addAll({"bankDetails": bankDetails})
          : data.addAll({"upiId": upi});
      try {
        final url = '${Base_url}astrobandhan/v1/astrologer/create/withdrawl';
        print(url);

        emit(state.copyWith(isSuccess: null));

        final response = await dio.post(url, data: data);

        final responseData = response.data;
        Helper.showSnack(Helper.navigatorKey, "comming soon");
        // if (response.statusCode == 200) {
        //   emit(state.copyWith(isLoading: false, isSuccess: true));
        // } else {
        //   final message = responseData['message'];

        //   emit(state.copyWith(isLoading: false, isSuccess: false));
        //   emit(state.copyWith(errorMessage: message));
        // }
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
