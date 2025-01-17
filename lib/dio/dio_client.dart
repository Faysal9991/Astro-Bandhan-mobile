import 'package:dio/dio.dart';

class DioClient {
  // Singleton pattern: private constructor
  DioClient._privateConstructor();

  static final DioClient instance = DioClient._privateConstructor();

  late Dio dio;

  // Initialize Dio instance with common settings
  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://ec2-15-206-90-111.ap-south-1.compute.amazonaws.com:8000/', // Base URL for all API calls
        connectTimeout: const Duration(seconds: 5), // Connection timeout
        receiveTimeout: const Duration(seconds: 3), // Response timeout
      ),
    );

    dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  // Method to get the Dio instance
  Dio getDio() {

    return dio;
  }
}
