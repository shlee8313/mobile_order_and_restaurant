// file: lib/services/order_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/api_config.dart';
import '../models/order.dart';
import 'package:get/get.dart';
import './auth_service.dart';
import './socket_service.dart';

class OrderService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final SocketService _socketService = Get.find<SocketService>();

  // Future<Order> saveOrder(Order order) async {
  //   try {
  //     final token = await _authService.getUserToken();
  //     if (token == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     print('Sending order to server: ${json.encode(order.toJson())}');

  //     final response = await http.post(
  //       Uri.parse('${ApiConfig.baseUrl}/api/orders/customer'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(order.toJson()),
  //     );

  //     print('Server response status: ${response.statusCode}');
  //     print('Server response body: ${response.body}');

  //     if (response.statusCode == 201) {
  //       final responseData = json.decode(response.body);
  //       if (responseData['success'] == true && responseData['data'] != null) {
  //         final savedOrder = Order.fromJson(responseData['data']);

  //         // 소켓 연결 및 저장된 주문 전송
  //         await _socketService.connect(order.restaurantId, 'customer',
  //             token: token);
  //         final socketResult =
  //             await _socketService.sendNewOrder(savedOrder.toJson());

  //         if (!socketResult['success']) {
  //           print(
  //               'Warning: Failed to send order via socket: ${socketResult['message']}');
  //         }

  //         return savedOrder;
  //       } else {
  //         throw Exception('Invalid response format');
  //       }
  //     } else {
  //       final errorMessage = _parseErrorMessage(response);
  //       throw Exception('Failed to save order: $errorMessage');
  //     }
  //   } catch (e) {
  //     print('Error processing order: $e');
  //     rethrow;
  //   }
  // }

  // String _parseErrorMessage(http.Response response) {
  //   try {
  //     final responseData = json.decode(response.body);
  //     return responseData['error'] ??
  //         responseData['message'] ??
  //         'Unknown error';
  //   } catch (_) {
  //     return response.body;
  //   }
  // }
}
