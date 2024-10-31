import 'package:dio/dio.dart';

class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}. ${error.response?.statusMessage}';
        case DioExceptionType.cancel:
          return 'Request was cancelled';
        default:
          return 'An unexpected error occurred: ${error.message}';
      }
    } else if (error is Exception) {
      return 'An error occurred: ${error.toString()}';
    }
    return 'An unknown error occurred';
  }
}
