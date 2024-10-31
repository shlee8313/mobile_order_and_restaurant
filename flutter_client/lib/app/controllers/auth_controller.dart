// file: lib/app/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../data/models/restaurant.dart';
import 'dart:convert';
import '../controllers/navigation_controller.dart';
import '../data/providers/api_provider.dart';
import '../controllers/order_controller.dart';
import '../controllers/quick_order_controller.dart';
import '../data/services/socket_service.dart'; // SocketService import 추가
import '../controllers/business_day_controller.dart';

/**
 * 
 */
class AuthController extends GetxController {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Rx<String?> _userToken = Rx<String?>(null);
  final Rx<Restaurant?> _restaurant = Rx<Restaurant?>(null);
  final Rx<String?> _restaurantToken = Rx<String?>(null);
  final ApiProvider apiProvider = Get.find();

  Rx<String?> get userToken => _userToken;
  Rx<Restaurant?> get restaurant => _restaurant;
  Rx<String?> get restaurantToken => _restaurantToken;
  final RxBool isLoggedInRx = false.obs;

  bool get isLoggedIn =>
      restaurantToken.value != null &&
      restaurantToken.value!.isNotEmpty &&
      restaurant.value != null;

  bool get isAuthenticated =>
      _userToken.value != null || _restaurantToken.value != null;

  // bool get isLoggedIn =>
  //     restaurantToken.value != null &&
  //     restaurantToken.value!.isNotEmpty &&
  //     restaurant.value != null;
// SocketService 인스턴스 추가
  // SocketService? _socketService;
  @override
  void onInit() {
    super.onInit();
    initializeState();
    ever(_restaurantToken, (_) => _updateLoggedInStatus());
    ever(_restaurant, (_) => _updateLoggedInStatus());
  }

  void _updateLoggedInStatus() {
    final newStatus = isLoggedIn;
    if (isLoggedInRx.value != newStatus) {
      isLoggedInRx.value = newStatus;
      // 주석: 로그인 상태가 변경될 때마다 로그 출력
      print(
          'Login status updated: $newStatus, Restaurant: ${_restaurant.value?.toJson()}');
    }
  }

  /**
   * 
   */
  Future<void> initializeState() async {
    try {
      _userToken.value = await _secureStorage.read(key: 'authToken');
      _restaurantToken.value =
          await _secureStorage.read(key: 'restaurantToken');

      final storedRestaurant = await _secureStorage.read(key: 'restaurant');
      if (storedRestaurant != null) {
        _restaurant.value = Restaurant.fromJson(json.decode(storedRestaurant));
        if (_restaurantToken.value != null) {
          apiProvider.setToken(_restaurantToken.value!);
          if (!await _isTokenValid()) {
            await refreshToken();
          }
        }
      }
    } catch (e) {
      print('Error initializing auth state: $e');
      await logout();
    }
  }

  // 수정된 _isTokenValid 메서드
  Future<bool> _isTokenValid() async {
    try {
      final response = await apiProvider.get('/api/auth/validate-token');
      if (response.statusCode == 200) {
        final restaurantData = response.data['restaurant'];
        _restaurant.value = Restaurant.fromJson(restaurantData);
        return true;
      }
      return false;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // 새로 추가된 refreshToken 메서드
  Future<void> refreshToken() async {
    try {
      final response = await apiProvider.post('/api/auth/refresh-token', {});
      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await setRestaurantToken(newToken);
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
    }
  }

  // Future<bool> _isTokenValid() async {
  //   try {
  //     final response = await apiProvider.get('/api/auth/validate-token');
  //     if (response.statusCode == 200) {
  //       final restaurantData = response.data['restaurant'];
  //       _restaurant.value = Restaurant.fromJson(restaurantData);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print('Token validation error: $e');
  //     return false;
  //   }
  // }

  Future<void> handleUnauthorized() async {
    await logout();
    Get.offAllNamed('/login');
    Get.snackbar('Session Expired', 'Please log in again.');
  }

  Future<void> setUserToken(String token) async {
    _userToken.value = token;
    await _secureStorage.write(key: 'authToken', value: token);
    apiProvider.setToken(token);
  }

  Future<void> setRestaurant(Restaurant restaurant) async {
    _restaurant.value = restaurant;
    await _secureStorage.write(
        key: 'restaurant', value: json.encode(restaurant.toJson()));
  }

  Future<void> setRestaurantToken(String token) async {
    _restaurantToken.value = token;
    await _secureStorage.write(key: 'restaurantToken', value: token);
    apiProvider.setToken(token);
  }

  Future<void> logoutRestaurant() async {
    _restaurant.value = null;
    _restaurantToken.value = null;
    await _secureStorage.delete(key: 'restaurant');
    await _secureStorage.delete(key: 'restaurantToken');
    apiProvider.setToken('');
  }

  Future<void> fullLogout() async {
    await logoutRestaurant();
    _userToken.value = null;
    await _secureStorage.delete(key: 'authToken');

    if (Get.isRegistered<SocketService>()) {
      final socketService = Get.find<SocketService>();
      await socketService.disconnect();
      Get.delete<SocketService>();
    }
    // NavigationController의 currentPage 초기화
    if (Get.isRegistered<NavigationController>()) {
      final navigationController = Get.find<NavigationController>();
      navigationController.setCurrentPage('Admin Dashboard'); // 기본값으로 초기화
    }
    /**
     * 
     */
    Get.delete<NavigationController>();
    Get.delete<AuthController>();
    // 테이블 유무에 따라 적절한 컨트롤러 삭제
    // 현재 사용 중인 컨트롤러만 삭제
    if (Get.isRegistered<OrderController>()) {
      Get.delete<OrderController>();
    }
    if (Get.isRegistered<QuickOrderController>()) {
      Get.delete<QuickOrderController>();
    }
  }

  Future<void> logout() async {
    // NavigationController의 currentPage 초기화
    if (Get.isRegistered<NavigationController>()) {
      final navigationController = Get.find<NavigationController>();
      navigationController.setCurrentPage('Admin Dashboard'); // 기본값으로 초기화
    }
    await fullLogout();
    _updateLoggedInStatus();
    Get.offAllNamed(
      '/login',
    );
  }

  Future<void> login(String restaurantId, String password) async {
    try {
      print('Login attempt for restaurantId: $restaurantId');
      final response = await apiProvider.post('/api/auth/login', {
        'restaurantId': restaurantId,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] as String?;
        final restaurantData =
            response.data['restaurant'] as Map<String, dynamic>?;

        if (token != null && restaurantData != null) {
          await setRestaurantToken(token);
          final restaurant = Restaurant.fromJson(restaurantData);
          await setRestaurant(restaurant);
          apiProvider.setToken(token);
          _updateLoggedInStatus();

          try {
            final businessDayController = Get.find<BusinessDayController>();
            final businessDay = await businessDayController
                .checkAndStartBusinessDay(restaurant.restaurantId);

            if (businessDay == null) {
              // Get.snackbar('알림', '영업일 정보를 가져오는데 실패했습니다.');
              print('영업일 정보를 가져오는데 실패했습니다.');
            } else if (!businessDay.isActive) {
              // Get.snackbar('알림', '현재 영업 중이 아닙니다. 영업을 시작하려면 영업마감 해제 버튼을 눌러주세요.');
              print('현재 영업 중이 아닙니다. 영업을 시작하려면 영업마감 해제 버튼을 눌러주세요.');
            } else {
              print('Active business day found: ${businessDay.id}');
            }
          } catch (e) {
            print('Error in BusinessDayController: $e');
            // Get.snackbar(
            //   '주의',
            //   '영업일 상태 확인 중 오류가 발생했습니다. 영업 상태를 수동으로 확인해주세요.',
            // );
            Get.snackbar(
              '주의',
              '영업일 상태 확인 중 오류가 발생했습니다. 영업 상태를 수동으로 확인해주세요.',
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 2),
              backgroundColor: Colors.black87,
              colorText: Colors.white,
            );
          }

          print('Login successful: ${restaurant.businessName}');
          print('Connected with restaurantId: ${restaurant.restaurantId}');

          // 여기에 로그인 성공 후 수행할 추가 작업을 넣을 수 있습니다.
          // 예: Get.offAll(() => HomePage());
        } else {
          throw Exception('Login failed: Invalid token or restaurant data');
        }
      } else {
        throw Exception('Login failed: Invalid response from server');
      }
    } catch (e) {
      print('Login error in AuthController: $e');
      // Get.snackbar(
      //   'Login Error',
      //   '로그인 중 오류가 발생했습니다: ${e.toString()}',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: Duration(seconds: 5),
      // );
      rethrow;
    }
  }
  /***
   * 
   */

  Future<void> register({
    required String email,
    required String password,
    required String businessName,
    required String address,
    required String phoneNumber,
    required String businessNumber,
    required String operatingHours,
    required String restaurantId,
    required bool hasTables,
    required int tables,
  }) async {
    try {
      final response = await apiProvider.post('/api/auth/register', {
        'email': email,
        'password': password,
        'businessName': businessName,
        'address': address,
        'phoneNumber': phoneNumber,
        'businessNumber': businessNumber,
        'operatingHours': operatingHours,
        'restaurantId': restaurantId,
        'hasTables': hasTables,
        'tables': tables,
      });

      if (response.statusCode == 201) {
        // Get.snackbar('Success', 'Registration successful');
        Get.offAllNamed('/admin');
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  /***
   * 
   */

  Future<bool> checkDuplicate(String field, String value) async {
    print('Checking duplicate for $field: $value');
    try {
      final response = await apiProvider.get(
        '/api/auth/check-duplicate',
        queryParameters: {
          'field': field,
          'value': value,
        },
      );
      // print('Response status: ${response.statusCode}');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final isDuplicate = response.data['isDuplicate'] ?? false;
        // print('Is duplicate: $isDuplicate');
        return isDuplicate;
      } else {
        print('Unexpected status code: ${response.statusCode}');
        return true; // Consider it as duplicate in case of unexpected response
      }
    } catch (e) {
      print('Error checking duplicate: $e');
      return true; // Consider it as duplicate in case of error
    }
  }
  /**
   * 
   */
}
