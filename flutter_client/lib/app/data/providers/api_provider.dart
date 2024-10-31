//file: \flutter_client\lib\app\data\providers\api_provider.dart

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../../core/values/env.dart';
import '../../controllers/auth_controller.dart'; // 추가: AuthController import

class ApiProvider extends GetxService {
  late dio.Dio _dio;
  final String baseUrl = Env.apiUrl;
  final RxString _token = ''.obs;

  String get token => _token.value;

  Future<ApiProvider> init() async {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 10),
      sendTimeout: Duration(seconds: 5),
      // 수정: 404 오류를 허용하도록 변경
      // validateStatus: (status) {
      //   return status! < 500;
      // },
    ));

    // 개발 환경에서만 로그 인터셉터를 추가합니다.
    if (Env.isDevelopment) {
      _dio.interceptors.add(dio.LogInterceptor(responseBody: true));
    }

    // 토큰이 변경될 때마다 헤더를 업데이트합니다
    ever(_token, (_) {
      _updateAuthHeader();
    });

    return this;
  }

  void setToken(String newToken) {
    _token.value = newToken;
  }

  void _updateAuthHeader() {
    if (_token.value.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer ${_token.value}';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // 수정: _handleResponse 메서드 추가
  Future<dio.Response> _handleResponse(dio.Response response) async {
    if (response.statusCode == 401) {
      final authController = Get.find<AuthController>();
      await authController.refreshToken();
      // 원래 요청 재시도
      return await retry(response.requestOptions);
    }
    return response;
  }

  // 수정: retry 메서드 추가
  Future<dio.Response> retry(dio.RequestOptions requestOptions) async {
    final options = dio.Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  Future<dio.Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(path, data: data);
      return await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response<dynamic>> put(String path, dynamic data) async {
    try {
      print('PUT Request to $path');
      print('Request data: $data');
      final response = await _dio.put(path, data: data);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return await _handleResponse(response);
    } catch (e) {
      print('Error in PUT request: $e');
      rethrow;
    }
  }

  /**
   * 
   */
  Future<dio.Response> patch(String path, dynamic data) async {
    try {
      final response = await _dio.patch(path, data: data);
      return await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

/**
 * 
 */
  Future<dio.Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return await _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is dio.DioException) {
      print('DioException: ${error.type}, ${error.message}');
      if (error.response != null) {
        print('Response data: ${error.response?.data}');
        print('Response headers: ${error.response?.headers}');
        print('Response status code: ${error.response?.statusCode}');
      }

      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          return ApiTimeoutException(error.message ?? 'Timeout error');
        case dio.DioExceptionType.badResponse:
          return ApiBadResponseException(
              error.response?.statusCode, error.response?.data);
        case dio.DioExceptionType.cancel:
          return ApiRequestCancelledException();
        default:
          return ApiUnknownException(error.message ?? 'Unknown error');
      }
    }
    print('Unknown error: $error');
    return ApiUnknownException(error.toString());
  }
}

// Custom exception classes
class ApiTimeoutException implements Exception {
  final String? message;
  ApiTimeoutException(this.message);
}

class ApiBadResponseException implements Exception {
  final int? statusCode;
  final dynamic data;
  ApiBadResponseException(this.statusCode, this.data);
}

class ApiRequestCancelledException implements Exception {}

class ApiUnknownException implements Exception {
  final String? message;
  ApiUnknownException(this.message);
}
