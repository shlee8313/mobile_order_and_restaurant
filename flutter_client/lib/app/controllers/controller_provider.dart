// File: lib/controllers/controller_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_client/app/controllers/order_controller.dart';
import 'package:get/get.dart';
import 'navigation_controller.dart';
import 'auth_controller.dart';
import 'sales_controller.dart';
// import 'order_controller.dart';
import 'table_controller.dart';
import 'order_queue_controller.dart';
import 'quick_order_controller.dart';
import 'menu_edit_controller.dart';
import '../data/services/socket_service.dart';
import '../controllers/business_day_controller.dart';
import '../data/providers/api_provider.dart';
import '../controllers/menu_edit_controller.dart';
// 주석: Restaurant 모델 import 추가
import '../data/models/restaurant.dart';

/***
 * 
 */
class ControllerBinding implements Bindings {
  @override
  void dependencies() {
    // 주석: 기본 컨트롤러들 초기화
    Get.put(AuthController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(SalesController(), permanent: true);
    Get.put(BusinessDayController(), permanent: true);
    Get.put(OrderQueueController(), permanent: true);
    Get.put(MenuEditController(), permanent: true);

    final authController = Get.find<AuthController>();

    // 주석: restaurant 변경 감지 및 처리
    ever(authController.restaurant, (restaurant) async {
      if (restaurant != null && authController.isLoggedIn) {
        print("Restaurant changed: ${restaurant.businessName}");
        await _handleRestaurantChange(restaurant, authController);
      }
    });
  }

  Future<void> _handleRestaurantChange(
    Restaurant restaurant,
    AuthController authController,
  ) async {
    try {
      // 주석: 1. 기존 서비스/컨트롤러 정리
      await _cleanupExistingServices(restaurant);

      // 주석: 2. 새로운 서비스/컨트롤러 초기화
      await _initializeServices(restaurant, authController);
    } catch (e) {
      print("Error in _handleRestaurantChange: $e");
      // 주석: 에러 발생시 사용자에게 알림
      Get.snackbar(
        '오류',
        '서비스 초기화 중 문제가 발생했습니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> _cleanupExistingServices(Restaurant restaurant) async {
    print("Cleaning up existing services...");

    // 주석: 1. 기존 SocketService 정리
    if (Get.isRegistered<SocketService>()) {
      final existingSocketService = Get.find<SocketService>();
      if (existingSocketService.restaurantId != restaurant.restaurantId) {
        print(
            "Disconnecting existing socket for restaurant: ${existingSocketService.restaurantId}");
        await existingSocketService.disconnect();
        Get.delete<SocketService>();
      } else {
        print("Existing SocketService will be reused");
        return; // 주석: 같은 레스토랑의 SocketService면 재사용
      }
    }

    // 주석: 2. 기존 컨트롤러들 제거
    if (Get.isRegistered<OrderController>()) {
      print("Removing existing OrderController");
      Get.delete<OrderController>();
    }
    if (Get.isRegistered<QuickOrderController>()) {
      print("Removing existing QuickOrderController");
      Get.delete<QuickOrderController>();
    }
    if (Get.isRegistered<TableController>()) {
      print("Removing existing TableController");
      Get.delete<TableController>();
    }
  }

  Future<void> _initializeServices(
    Restaurant restaurant,
    AuthController authController,
  ) async {
    try {
      print("Initializing services for restaurant: ${restaurant.restaurantId}");

      // 주석: 1. SocketService 초기화
      final socketService = SocketService(
        restaurantId: restaurant.restaurantId,
        isAdmin: true,
        token: authController.restaurantToken.value,
      );

      // 주석: 2. 테이블 유무에 따른 컨트롤러 초기화
      if (restaurant.hasTables) {
        print("Initializing controllers for restaurant with tables");
        final orderController = Get.put(OrderController(), permanent: true);
        Get.put(TableController(), permanent: true);
        socketService.setOrderController(orderController);
      } else {
        print("Initializing controllers for restaurant without tables");
        final quickOrderController =
            Get.put(QuickOrderController(), permanent: true);
        socketService.setQuickOrderController(quickOrderController);
      }

      // 주석: 3. SocketService 초기화 및 등록
      await socketService.init();
      Get.put(socketService, permanent: true);

      print(
          "Services initialized successfully for restaurant: ${restaurant.restaurantId}");
    } catch (e) {
      print("Error initializing services: $e");
      // 주석: 5초 후 재시도
      await Future.delayed(Duration(seconds: 5));
      print("Retrying service initialization...");
      return _initializeServices(restaurant, authController);
    }
  }
}

class ControllerProvider extends StatelessWidget {
  final Widget child;

  const ControllerProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      home: child,
    );
  }
}
