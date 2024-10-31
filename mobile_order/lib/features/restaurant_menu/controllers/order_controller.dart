// file: lib/features/restaurant_menu/controllers/order_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/socket_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/order.dart';
import '../../../models/visit_count.dart'; // VisitCount 모델 import
import './restaurant_menu_controller.dart';
import '../../../core/config/api_config.dart';
import 'dart:async';

class OrderController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  final AuthService _authService = Get.find<AuthService>();
  // final RestaurantMenuController _menuController =
  //     Get.find<RestaurantMenuController>();

  final RxBool isLoading = false.obs;
  final String restaurantId;

  OrderController({required this.restaurantId});

  Future<void> placeOrder(Order order) async {
    isLoading.value = true;
    try {
      // final restaurantId = _menuController.restaurantId;
      final token = await _authService.getUserToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // 1. HTTP를 통한 주문 저장
      final savedOrder = await _saveOrderToDatabase(order, token);

      // 2. 방문 횟수 증가
      await _incrementVisitCount(restaurantId, token);

      // 2. 소켓 서비스에 연결
      await _socketService.connect(restaurantId, 'customer', token: token);

      // 3. 저장된 주문 데이터를 소켓으로 전송
      final result = await _socketService.sendNewOrder(savedOrder.toJson());

      if (result['success']) {
        Get.snackbar('주문 성공', '주문이 성공적으로 접수되었습니다.',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.black);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Get.snackbar('주문 실패', '주문 처리 중 오류가 발생했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _incrementVisitCount(String restaurantId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/visits/increment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'restaurantId': restaurantId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to increment visit count: ${response.body}');
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(
            'Failed to increment visit count: ${responseData['message']}');
      }

      // 업데이트된 방문 횟수를 로그로 출력 (선택사항)
      print('Updated visit count: ${responseData['data']['count']}');
    } catch (e) {
      print('Error incrementing visit count: $e');
      // 여기서는 예외를 다시 던지지 않습니다. 방문 횟수 증가 실패가 주문 처리를 중단시키지 않도록 합니다.
    }
  }

  Future<Order> _saveOrderToDatabase(Order order, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/orders/customer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return Order.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to save order: ${response.body}');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // final restaurantId = _menuController.restaurantId;
      final token = await _authService.getUserToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // 1. HTTP를 통한 상태 업데이트
      final updatedOrder =
          await _updateOrderStatusInDatabase(orderId, status, token);

      // 2. 소켓 서비스에 연결
      await _socketService.connect(restaurantId, 'customer', token: token);

      // 3. 업데이트된 주문 상태를 소켓으로 전송
      final completer = Completer<Map<String, dynamic>>();

      _socketService.emit('updateOrderStatus', updatedOrder.toJson(),
          (response) {
        completer.complete(response as Map<String, dynamic>);
      });

      final result = await completer.future;

      if (result['success'] == true) {
        Get.snackbar('상태 업데이트', '주문 상태가 업데이트되었습니다.');
      } else {
        throw Exception(result['message'] ?? '상태 업데이트 실패');
      }
    } catch (e) {
      Get.snackbar('업데이트 실패', '주문 상태 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  Future<Order> _updateOrderStatusInDatabase(
      String orderId, String status, String token) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/orders/$orderId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return Order.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to update order status: ${response.body}');
    }
  }

  Future<List<Order>> getCustomerOrders(String restaurantId) async {
    try {
      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/orders/customer?restaurantId=$restaurantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return (responseData['data'] as List)
              .map((orderJson) => Order.fromJson(orderJson))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch orders: ${response.body}');
      }
    } catch (e) {
      print('Error fetching customer orders: $e');
      return [];
    }
  }
}
