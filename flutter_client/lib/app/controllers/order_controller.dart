//file: \flutter_client\lib\app\controllers\order_controller.dart

import 'package:get/get.dart';
import '../data/models/order.dart';
import '../data/providers/api_provider.dart';
import './auth_controller.dart';
import 'package:flutter/material.dart' show Color, Colors;
// import '../data/models/table_model.dart';
import './sales_controller.dart'; // Import SalesController
// import '../data/services/socket_service.dart';
import '../controllers/table_controller.dart';
import './order_queue_controller.dart'; // 추가

import './business_day_controller.dart'; // 추가
import '../data/services/audio_service.dart';

/**
 * 
 */
class OrderController extends GetxController {
  final AuthController authController = Get.find();
  final ApiProvider apiProvider = Get.find();
  final AudioService _audioService = Get.find<AudioService>();
  final SalesController salesController = Get.find<SalesController>();
  final OrderQueueController orderQueueController =
      Get.find<OrderQueueController>(); // 추가
  final RxList<Order> _orders = <Order>[].obs;
  List<Order> get orders => _orders;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  // final List<TableModel> _tables = <TableModel>[].obs;
  // final SocketService _socketService = Get.find<SocketService>();
/**
 * 
 */
  @override
  void onInit() {
    super.onInit();
    // _initializeSocket();
    ever(authController.restaurantToken, _onTokenChanged);
    fetchOrders(); // 초기 로딩 시 주문 데이터 가져오기
  }

  void _onTokenChanged(String? token) {
    if (token != null && token.isNotEmpty) {
      fetchOrders();
    } else {
      _orders.clear();
    }
  }

//   void _initializeSocket() {
//   final socketService = Get.find<SocketService>();
//   socketService.listenForNewOrders(handleNewOrder);
// }

  void handleNewOrder(dynamic data) {
    if (data['isQuickOrder'] == true) {
      // QuickOrder이므로 여기서 처리하지 않음
      return;
    }
    print("New order received in controller: $data");
    try {
      String orderId = data['_id'] ?? DateTime.now().toIso8601String();
      DateTime createdAt =
          DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String());

      // 중복 주문 체크 로직
      if (_isDuplicateOrder(orderId, createdAt)) {
        print("Duplicate order detected. Ignoring...");
        return;
      }

      List<OrderItem> orderItems = _createOrderItems(data['items']);
      int totalAmount = _calculateTotalAmount(orderItems);

      Order newOrder = Order(
        id: orderId,
        restaurantId: data['restaurantId'] ?? '',
        businessDayId: data['businessDayId']?.toString(),
        tableId: int.parse(data['tableId']?.toString() ?? '0'),
        items: orderItems,
        status: data['status'] ?? 'pending',
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        totalAmount: totalAmount,
        isComplimentaryOrder: totalAmount == 0,
        user: data['user'] ?? '',
      );

      _processOrder(newOrder);
    } catch (e) {
      print("Error handling new order: $e");
      Get.snackbar('오류', '새 주문을 처리하는 중 오류가 발생했습니다.');
    }
  }

  bool _isDuplicateOrder(String orderId, DateTime createdAt) {
    return _orders.any((order) =>
        order.id == orderId ||
        (order.createdAt.difference(createdAt).abs().inSeconds < 5 &&
            order.items.length == 1 &&
            order.items[0].price == 0));
  }

  List<OrderItem> _createOrderItems(List<dynamic>? itemsData) {
    return (itemsData ?? []).map((itemData) {
      return OrderItem.fromJson(itemData);
    }).toList();
  }

  int _calculateTotalAmount(List<OrderItem> items) {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _processOrder(Order newOrder) {
    _orders.add(newOrder);
    orderQueueController.addToOrderQueue(newOrder);

    Get.find<TableController>()
        .updateTable(newOrder.tableId.toString(), {'status': 'occupied'});

    _audioService.playOrderSound(); // 새 주문이 있을 때 소리 재생
    String message = newOrder.isComplimentaryOrder
        ? '테이블 ${newOrder.tableId}에서 ${newOrder.items[0].name} 요청이 접수되었습니다.'
        : '테이블 ${newOrder.tableId}에서 ${newOrder.items[0].name} 주문이 접수되었습니다.';

    Get.snackbar(
      newOrder.isComplimentaryOrder ? '새로운 요청' : '새로운 주문',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );

    print("Order processed. Current order count: ${_orders.length}");
    update();
  }
/**
 * 
 */

  Future<List<Order>> fetchOrders() async {
    if (!authController.isLoggedIn) {
      print('User is not logged in. Skipping fetch.');
      return [];
    }
    _isLoading.value = true;
    try {
      final response = await apiProvider.get(
        '/api/orders',
        queryParameters: {
          'restaurantId': authController.restaurant.value?.restaurantId
        },
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;

          // if (responseData['status'] == 'no_active_business_day') {
          //   print('No active business day found. Starting a new one.');
          //   final businessDayController = Get.find<BusinessDayController>();
          //   await businessDayController.startNewBusinessDay(
          //       authController.restaurant.value?.restaurantId ?? '');
          //   return fetchOrders();
          // }
          if (responseData['status'] == 'no_active_business_day') {
            print('No active business day found.');
            // Get.snackbar('알림', '현재 영업 중이 아닙니다. 영업을 시작해주세요.');
            return [];
          }
          /**
           * 
           */
          final ordersList = responseData['data'] as List? ?? [];
          final orders = _parseOrders(ordersList);
          _orders.assignAll(orders);
          orderQueueController.initializeOrderQueue(orders);
          return orders;
        } else if (response.data is List) {
          final ordersList = response.data as List;
          final orders = _parseOrders(ordersList);
          _orders.assignAll(orders);
          orderQueueController.initializeOrderQueue(orders);
          return orders;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } catch (error) {
      print('Error fetching orders: $error');
      Get.snackbar('Error', 'Failed to load orders');
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  List<Order> _parseOrders(List ordersList) {
    return ordersList
        .map((orderJson) {
          try {
            return Order.fromJson(orderJson);
          } catch (e) {
            print('Error parsing order: $e');
            return null;
          }
        })
        .whereType<Order>()
        .toList();
  }

/**
 * 
 */

  Future<void> updateOrderStatus(int tableId, Order order) async {
    try {
      String newStatus = _getNextStatus(order.status);

      final response = await apiProvider.patch(
        '/api/orders',
        {
          'restaurantId': authController.restaurant.value?.restaurantId,
          'tableId': tableId,
          'orderId': order.id,
          'newStatus': newStatus,
          'user': order.user, // 추가
          'businessDayId': order.businessDayId, // 추가
        },
      );

      if (response.statusCode == 200) {
        final updatedOrder = Order.fromJson(response.data['order']);
        final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
        // 업데이트된 대기열 정보 처리
        // OrderQueueController 업데이트
        orderQueueController.updateOrderInQueue(updatedOrder);
        // 새로 추가된 부분:
        if (response.data['meta'] != null &&
            response.data['meta']['businessDayId'] != null) {
          Get.find<BusinessDayController>().currentBusinessDayId.value =
              response.data['meta']['businessDayId'];
        }
        update(); // 화면 강제 갱신
        if (newStatus == 'completed') {
          await salesController
              .fetchTodaySales(authController.restaurant.value?.restaurantId);
        }
        // Get.snackbar('성공', '주문 상태가 업데이트되었습니다.');
      } else {
        throw Exception(
            'Failed to update order status: ${response.statusMessage}');
      }
    } catch (error) {
      print('Error updating order status: $error');
      Get.snackbar('Error', 'Failed to update order status');
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'preparing';
      case 'preparing':
        return 'served';
      case 'served':
        return 'completed';
      default:
        return currentStatus;
    }
  }

/**
 * 
 */
// 결제버튼 클릭
  Future<void> handlePayment(int tableId) async {
    try {
      final response = await apiProvider.patch(
        '/api/orders',
        {
          'restaurantId': authController.restaurant.value?.restaurantId,
          'tableId': tableId,
          'action': 'completeAllOrders',
        },
      );

      if (response.statusCode == 200) {
        _orders.removeWhere((order) => order.tableId == tableId);
        update(); // 상태 업데이트 후 UI 갱신 트리거
        // Fetch and update today's sales data after the order status update

        final restaurantId = authController.restaurant.value?.restaurantId;
        final token = authController.restaurantToken.value;
        if (restaurantId != null && token != null) {
          await salesController.fetchTodaySales(restaurantId);
        }

        // Get.snackbar('Success', 'All orders for table $tableId completed');
      } else {
        throw Exception('Failed to complete orders: ${response.statusMessage}');
      }
    } catch (error) {
      _handleError(error, 'Failed to complete orders');
    }
  }

/**
 * 
 */
// 호출 controll, 가격이 0인 경우
  Future<void> handleCallComplete(int tableId, Order order) async {
    try {
      // Check if the order contains only items with price 0
      if (order.items.every((item) => item.price == 0)) {
        // Update the order status in the database
        final response = await apiProvider.patch(
          '/api/orders',
          {
            'restaurantId': authController.restaurant.value?.restaurantId,
            'tableId': tableId,
            'orderId': order.id,
            'action': 'completeCall',
          },
        );

        if (response.statusCode == 200) {
          // Remove the order from the local list
          _orders.removeWhere((o) => o.id == order.id);

          // Remove the order from the queue
          orderQueueController.removeFromQueue(order.id);

          // Update the UI
          update();

          // Get.snackbar('Success', '호출이 완료되었습니다.');
        } else {
          throw Exception(
              'Failed to update order status: ${response.statusMessage}');
        }
      } else {
        throw Exception('The order contains items with non-zero prices.');
      }
    } catch (error) {
      print('Error in handleCallComplete: $error');
      Get.snackbar('Error', '호출 완료 처리 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /**
   * 
   */
  void _handleError(dynamic error, String defaultMessage) {
    String errorMessage = defaultMessage;
    if (error is ApiTimeoutException) {
      errorMessage = 'Request timed out. Please try again.';
    } else if (error is ApiBadResponseException) {
      errorMessage = 'Server error: ${error.statusCode}';
    } else if (error is ApiRequestCancelledException) {
      errorMessage = 'Request was cancelled';
    } else if (error is ApiUnknownException) {
      errorMessage = 'An unknown error occurred: ${error.message}';
    }
    print('Error: $errorMessage');
    Get.snackbar('Error', errorMessage);
  }

  void _updateOrderQueue(List<Order> updatedQueue) {
    // 대기열에 있는 주문들만 업데이트
    final queueOrderIds = updatedQueue.map((o) => o.id).toSet();
    _orders.removeWhere((o) => queueOrderIds.contains(o.id));
    _orders.addAll(updatedQueue);
    _orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '주문접수';
      case 'preparing':
        return '준비중';
      case 'served':
        return '서빙완료';
      case 'completed':
        return '완료';
      default:
        return '알 수 없음';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'preparing':
        return Colors.yellow;
      case 'served':
        return Colors.grey;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
