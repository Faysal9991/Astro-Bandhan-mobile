import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dio/Constant.dart';
import '../dio/dio_client.dart';

class CreateAccountState {

  final bool accountCreated;
  final bool isLoading;
  final bool isTimeOfBirthEnabled;
  final String? selectedHour;
  final String? selectedMinute;
  final String? selectedPeriod;
  final String? selectedGender;
  final String? placeOfBirth;
  final String? selectedDOB;
  final String? isError;



  CreateAccountState({
    this.accountCreated = false,
    this.isLoading = false, // Default is not loading
    this.isTimeOfBirthEnabled = false,
    this.selectedHour,
    this.selectedMinute,
    this.selectedPeriod,
    this.selectedGender,
    this.placeOfBirth,
    this.selectedDOB,
    this.isError,
  });

  CreateAccountState copyWith({
    bool? accountCreated,
    bool? isLoading,
    bool? isTimeOfBirthEnabled,
    String? selectedHour,
    String? selectedMinute,
    String? selectedPeriod,
    String? selectedGender,
    String? placeOfBirth,
    String? selectedDOB,
    String? isError,
  }) {
    return CreateAccountState(
      accountCreated: accountCreated ?? this.accountCreated,
      isLoading: isLoading ?? this.isLoading,
      isTimeOfBirthEnabled: isTimeOfBirthEnabled ?? this.isTimeOfBirthEnabled,
      selectedHour: selectedHour ?? this.selectedHour,
      selectedMinute: selectedMinute ?? this.selectedMinute,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedGender: selectedGender ?? this.selectedGender,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      selectedDOB: selectedDOB ?? this.selectedDOB,
      isError: isError ?? this.isError,
    );
  }

}

class CreateAccountCubit extends Cubit<CreateAccountState> {

  final Dio dio = DioClient.instance.getDio();

  CreateAccountCubit() : super(CreateAccountState());

  void toggleTimeOfBirth(bool value) {

    emit(state.copyWith(isTimeOfBirthEnabled: value));

  }

  void updateTimeOfBirth(String? hour, String? minute, String? period) {
    emit(state.copyWith(
      selectedHour: hour,
      selectedMinute: minute,
      selectedPeriod: period,
    ));
  }

  void updateDOB(String? dob) {
    emit(state.copyWith(selectedDOB: dob));
  }

  void updateGender(String? gender) {
    emit(state.copyWith(selectedGender: gender));
  }

  Future<void> createAccount(
      String name,
      String email,
      String phoneNumber,
      String dob,
      String gender,
      String placeOfBirth,
      String timeofbirth,
      String password)
  async {

    try {

      emit(state.copyWith(isLoading: true)); // Show loader when the API call starts

      print("timeofbirth");
      print(placeOfBirth);

      final url = '${base_upi}signup/astrologer'; // This will be appended to the baseUrl in DioClient
      print(url);

      final Map<String, dynamic> data = {
        'name': "${name}",
        'email': "${email}",
        "available": {
          "isAvailable": true,
          "isCallAvailable": true,
          "isChatAvailable": true,
          "isVideoCallAvailable": false
        },
        "isFeatured":true,
        "isVerified": true,
        "experience": 10,
        "pricePerCallMinute": 15,
        "pricePerChatMinute": 10,
        'phone': "${phoneNumber}",
        'dateOfBirth': "${dob}",
        'gender': "${gender}",
        "timeOfBirth": "${state.selectedHour}:${state.selectedMinute} ${state.selectedPeriod ==  "AM" ? "AM" : "PM"}",
        'placeOfBirth': "${placeOfBirth}",
        'password': "${password}",
        "specialities": ["Vedic", "Numerology"],
        "languages": ["672edc06d14603b8c9124c0b", "672edc1cd14603b8c9124c11"],
      };

      print(data);


      final response = await dio.post(url, data: data);

      print(response);

      if (response.statusCode == 200) {

        final responseData = response.data;
        print('Account created successfully: $responseData');

        emit(state.copyWith(accountCreated: true, isLoading: false));

        final accessToken = responseData['data']['accessToken'];
        final refreshToken = responseData['data']['refreshToken'];
        final message = responseData['message'];


        print('Account created successfully: $responseData');


        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        emit(state.copyWith(accountCreated: true, isLoading: false));
        emit(state.copyWith(isError: message));

      } else {

        emit(state.copyWith(accountCreated: false, isLoading: false));

      }

    } catch (error) {

      print('Error: $error');

      if (error is DioException) {

        print('Error status code: ${error.response?.statusCode}');
        print('Error message: ${error.response?.data}');

      }

      emit(state.copyWith(accountCreated: false, isLoading: false));

    }
  }

}
