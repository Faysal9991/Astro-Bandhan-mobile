
import 'package:astrologerapp/Wallet/model/walet_history.dart';
import 'package:astrologerapp/dio/Constant.dart';
import 'package:astrologerapp/dio/dio_client.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalateState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final bool toggleValue; // New boolean state
  final String? errorMessage;

  const WalateState({
    this.isLoading = false,
    this.isSuccess = false,
    this.toggleValue = true, // Default value for the toggle
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, isSuccess, toggleValue, errorMessage];

  WalateState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? toggleValue, // Optional parameter for the toggle state
    String? errorMessage,
  }) {
    return WalateState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      toggleValue: toggleValue ?? this.toggleValue,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}


List<WaletHistory> waletHistory = [];

// Login Cubit
class WalateCubit extends Cubit<WalateState> {
  WalateCubit() : super(const WalateState());

  Future<void> getWalateHistory() async {
    final Dio dio = DioClient.instance.getDio();

    emit(state.copyWith(isLoading: true));
    final prefs = await SharedPreferences.getInstance();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      final Map<String, dynamic> data = {
        "userId": prefs.getString('astrologer_id'),
        "type": "astrologer"
      };

      try {
        final url = '${Base_url}astrobandhan/v1/user/get/wallet/history';
        print(url);

        emit(state.copyWith(isSuccess: null));

        final response = await dio.post(url, data: data);
       
        final responseData = response.data;

        if (response.statusCode == 200) {
          responseData.forEach((element) async {
            waletHistory.add( WaletHistory.fromJson(element));
          });
         
          print("walatel history------>${waletHistory.length}");
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


void toggleBoolean() {
    emit(state.copyWith(toggleValue: !state.toggleValue));
  }
}
