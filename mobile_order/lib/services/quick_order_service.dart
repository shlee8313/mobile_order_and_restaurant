// file: lib/services/quick_order_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/api_config.dart';
import '../models/quick_order.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import './socket_service.dart';

class QuickOrderService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final SocketService _socketService = Get.find<SocketService>();

  // Future<QuickOrder> saveQuickOrder(QuickOrder quickOrder) async {
  //   try {
  //     final token = await _authService.getUserToken();
  //     if (token == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     // HTTP를 통한 퀵오더 저장
  //     final response = await http.post(
  //       Uri.parse('${ApiConfig.baseUrl}/api/quick-orders/customer'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(quickOrder.toJson()),
  //     );

  //     if (response.statusCode == 201) {
  //       final responseData = json.decode(response.body);
  //       if (responseData['success'] == true && responseData['data'] != null) {
  //         final savedQuickOrder = QuickOrder.fromJson(responseData['data']);

  //         // 소켓 연결 및 저장된 퀵오더 전송
  //         await _socketService.connect(quickOrder.restaurantId, 'customer',
  //             token: token);
  //         final socketResult =
  //             await _socketService.sendNewQuickOrder(savedQuickOrder.toJson());

  //         if (!socketResult['success']) {
  //           print(
  //               'Warning: Failed to send quick order via socket: ${socketResult['message']}');
  //         }

  //         return savedQuickOrder;
  //       } else {
  //         throw Exception('Invalid response format');
  //       }
  //     } else {
  //       final errorMessage = _parseErrorMessage(response);
  //       throw Exception('Failed to save quick order: $errorMessage');
  //     }
  //   } catch (e) {
  //     print('Error processing quick order: $e');
  //     rethrow;
  //   } finally {
  //     // _socketService.disconnect();
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
