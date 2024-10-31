// file: lib/app/modules/auth/login/login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
// import '../../../data/providers/auth_api.dart';
import '../../../controllers/auth_controller.dart';
// import '../../../data/models/restaurant.dart';
import '../../../controllers/table_controller.dart';
import '../../../controllers/order_controller.dart';

class LoginController extends GetxController {
  // final AuthApi authApi = Get.find<AuthApi>();
  final AuthController authController = Get.find<AuthController>();
  // TableController와 OrderController를 nullable로 변경
  TableController? tableController;
  OrderController? orderController;

  final restaurantId = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  void setRestaurantId(String value) => restaurantId.value = value;
  void setPassword(String value) => password.value = value;

  Future<void> login() async {
    if (restaurantId.value.isEmpty || password.value.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    isLoading.value = true;

    try {
      await authController.login(restaurantId.value, password.value);

      // 로그인 성공 후 레스토랑 정보 확인
      final restaurant = authController.restaurant.value;
      if (restaurant != null && restaurant.hasTables) {
        // 테이블이 있는 경우에만 컨트롤러 초기화 및 데이터 로드
        print('Restaurant has tables. Loading initial data...');
        await _loadInitialData();
      } else {
        print('Restaurant has no tables. Skipping initial data load.');
      }

      Get.offAllNamed('/admin');
    } catch (e) {
      print('Login error: $e');
      if (e is dio.DioException) {
        print('DioError: ${e.message}');
        if (e.response != null) {
          print('DioError response: ${e.response?.data}');
          _showErrorDialog(
              e.response?.data['message'] ?? 'An unknown error occurred');
        } else {
          _showErrorDialog('Network error occurred');
        }
      } else {
        _showErrorDialog('로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // 컨트롤러 초기화
      if (!Get.isRegistered<TableController>()) {
        Get.put(TableController(), permanent: true);
      }
      if (!Get.isRegistered<OrderController>()) {
        Get.put(OrderController(), permanent: true);
      }

      tableController = Get.find<TableController>();
      orderController = Get.find<OrderController>();

      // 데이터 로드
      await tableController?.fetchTables();
      await orderController?.fetchOrders();
    } catch (e) {
      print('Error loading initial data: $e');
      Get.snackbar(
        'Warning',
        'Some data could not be loaded. Please refresh the page.',
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Login 실패',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
