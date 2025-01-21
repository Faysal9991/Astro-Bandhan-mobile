import 'dart:convert';
import 'package:astrologerapp/Wallet/model/bank_details.dart';
import 'package:astrologerapp/dio/Constant.dart';
import 'package:astrologerapp/dio/dio_client.dart';
import 'package:astrologerapp/helper/navigator_helper.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class WithdrawState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;

  const WithdrawState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  @override
  List<Object?> get props =>
      [isLoading, isSuccess, errorMessage, successMessage];

  WithdrawState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
  }) {
    return WithdrawState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
class WithdrawCubit extends Cubit<WithdrawState> {
  WithdrawCubit() : super(const WithdrawState());

  Future<void> withdrawRequest({
    required int ammount,
    required String withdrawType,
    BankDetails? bankDetails,
    String? upi,
    required BuildContext context,
  }) async {
    final Dio dio = DioClient.instance.getDio();

    emit(state.copyWith(isLoading: true));
    final prefs = await SharedPreferences.getInstance();
    try {
      final Map<String, dynamic> data = {
        "astrologerId": prefs.getString('astrologer_id'),
        "amount": ammount,
        "withdrawalType": withdrawType.toLowerCase(),
      };

      withdrawType == "Bank"
          ? data.addAll({"bankDetails": bankDetails!.toJson()})
          : data.addAll({"upiId": upi});

      final url = '${Base_url}astrobandhan/v1/astrologer/create/withdrawl';
      final response = await dio.post(url, data: data);
      final responseData = response.data;

      if (response.statusCode == 200) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: responseData['message'] ??
              "Withdrawal request created successfully",
        ));
      } else {
        final message = responseData['message'] ?? "Transaction failed";
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: message,
        ));
      }
    } on DioException catch (error) {
      final errorMessage =
          error.response?.data?['message'] ?? "Transaction failed";
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
