// File: lib/app/controllers/order_queue_controller.dart

import 'package:get/get.dart';
import '../data/models/order.dart';
import '../data/providers/api_provider.dart';

class OrderQueueController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final RxList<Order> orderQueue = <Order>[].obs;
  final RxMap<String, int> orderNumbers = <String, int>{}.obs;

  void initializeOrderQueue(List<Order> orders) {
    orderQueue.assignAll(orders.where(
        (order) => order.status != 'served' && order.status != 'completed'));
    _sortQueue();
    _assignOrderNumbers();
    // printQueueDebug();
  }

  void addToOrderQueue(Order order) {
    if (order.status != 'served' && order.status != 'completed') {
      orderQueue.add(order);
      _sortQueue();
      _assignOrderNumbers();
      // printQueueDebug();
    }
  }

/**
 * 
 */
  void removeFromQueue(String orderId) {
    orderQueue.removeWhere((order) => order.id == orderId);
    _assignOrderNumbers();
    // printQueueDebug();
  }

  void updateOrderInQueue(Order updatedOrder) {
    final index = orderQueue.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      if (updatedOrder.status == 'served' ||
          updatedOrder.status == 'completed') {
        orderQueue.removeAt(index);
      } else {
        orderQueue[index] = updatedOrder;
      }
      _sortQueue();
      _assignOrderNumbers();
      // printQueueDebug();
    }
  }

  void _sortQueue() {
    orderQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _assignOrderNumbers() {
    orderNumbers.clear();
    for (int i = 0; i < orderQueue.length; i++) {
      orderNumbers[orderQueue[i].id] = i + 1;
    }
  }

  int getOrderNumber(String orderId) {
    return orderNumbers[orderId] ?? 0;
  }

  void printQueueDebug() {
    print('Current order queue (${orderQueue.length} orders):');
    for (var order in orderQueue) {
      print(
          'ID: ${order.id}, Table: ${order.tableId}, Status: ${order.status}, Order Number: ${getOrderNumber(order.id)}, Created: ${order.createdAt}');
    }
  }

  // void _handleError(dynamic error, String defaultMessage) {
  //   String errorMessage = defaultMessage;
  //   if (error is ApiTimeoutException) {
  //     errorMessage = 'Request timed out. Please try again.';
  //   } else if (error is ApiBadResponseException) {
  //     errorMessage = 'Server error: ${error.statusCode}';
  //   } else if (error is ApiRequestCancelledException) {
  //     errorMessage = 'Request was cancelled';
  //   } else if (error is ApiUnknownException) {
  //     errorMessage = 'An unknown error occurred: ${error.message}';
  //   } else if (error is Exception) {
  //     errorMessage = error.toString();
  //   }
  //   print('Error: $errorMessage');
  //   Get.snackbar('Error', errorMessage);
  // }
}
