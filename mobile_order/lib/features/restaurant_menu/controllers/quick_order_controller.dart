// file: lib/features/restaurant_menu/controllers/quick_order_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/socket_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/quick_order.dart';
import '../../../models/visit_count.dart'; // VisitCount 모델 import
import './restaurant_menu_controller.dart';
import '../../../core/config/api_config.dart';
import 'dart:async';

class QuickOrderController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final String restaurantId; // 주석: restaurantId를 클래스 속성으로 추가

  // 주석: 생성자에서 restaurantId를 받도록 수정
  QuickOrderController({required this.restaurantId});

  Future<void> placeQuickOrder(QuickOrder quickOrder) async {
    isLoading.value = true;
    try {
      final token = await _authService.getUserToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // 1. HTTP를 통한 퀵오더 저장
      final savedQuickOrder =
          await _saveQuickOrderToDatabase(quickOrder, token);
      print('Saved QuickOrder: ${savedQuickOrder.toJson()}');

      // 2. 방문 횟수 증가
      await _incrementVisitCount(restaurantId, token);

      // 3. 소켓 서비스에 연결
      await _socketService.connect(restaurantId, 'customer', token: token);

      // 4. 저장된 퀵오더 데이터를 소켓으로 전송
      final result =
          await _socketService.sendNewQuickOrder(savedQuickOrder.toJson());

      if (result['success']) {
        Get.snackbar(
          '주문 성공',
          '', // title만 사용하고 message는 비워둠
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          titleText: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   '주문 성공',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 4),
              Text(
                '주문번호: ${savedQuickOrder.orderNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // 주문번호 글자 크기 키움
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '주문이 성공적으로 접수되었습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Get.snackbar('주문 실패', '퀵오더 처리 중 오류가 발생했습니다: $e');
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

  Future<QuickOrder> _saveQuickOrderToDatabase(
      QuickOrder quickOrder, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/quick-orders/customer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(quickOrder.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return QuickOrder.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to save quick order: ${response.body}');
    }
  }

  Future<void> updateQuickOrderStatus(String orderId, String status) async {
    try {
      final token = await _authService.getUserToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // 1. HTTP를 통한 상태 업데이트
      final updatedQuickOrder =
          await _updateQuickOrderStatusInDatabase(orderId, status, token);

      // 2. 소켓 서비스에 연결
      await _socketService.connect(restaurantId, 'customer', token: token);

      // 3. 업데이트된 퀵오더 상태를 소켓으로 전송
      // 주석: Completer를 사용하여 비동기 응답 처리
      final completer = Completer<Map<String, dynamic>>();

      _socketService.emit('updateQuickOrderStatus', updatedQuickOrder.toJson(),
          (response) {
        completer.complete(response as Map<String, dynamic>);
      });

      final result = await completer.future;

      if (result['success'] == true) {
        Get.snackbar('상태 업데이트', '퀵오더 상태가 업데이트되었습니다.');
      } else {
        throw Exception(result['message'] ?? '상태 업데이트 실패');
      }
    } catch (e) {
      Get.snackbar('업데이트 실패', '퀵오더 상태 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  Future<QuickOrder> _updateQuickOrderStatusInDatabase(
      String orderId, String status, String token) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/quick-orders/$orderId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return QuickOrder.fromJson(responseData['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to update quick order status: ${response.body}');
    }
  }

  Future<List<QuickOrder>> getCustomerQuickOrders(String restaurantId) async {
    try {
      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/quick-orders/customer?restaurantId=$restaurantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return (responseData['data'] as List)
              .map((orderJson) => QuickOrder.fromJson(orderJson))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch quick orders: ${response.body}');
      }
    } catch (e) {
      print('Error fetching customer quick orders: $e');
      return [];
    }
  }
}
