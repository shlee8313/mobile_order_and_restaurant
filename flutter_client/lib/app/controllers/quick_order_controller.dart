//file: \flutter_client\lib\app\controllers\quick_order_controller.dart

//file: \flutter_client\lib\app\controllers\quick_order_controller.dart

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/models/quick_orders.dart';
import '../data/providers/api_provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sales_controller.dart';
import '../../core/utils/error_handler.dart';
import '../controllers/business_day_controller.dart'; // 추가
import '../data/services/socket_service.dart';
import '../data/services/audio_service.dart';

/**
 * 
 */
class QuickOrderController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AudioService _audioService = Get.find<AudioService>();
  final AuthController _authController = Get.find<AuthController>();
  final SalesController _salesController = Get.find<SalesController>();
  // final SocketService _socketService = Get.find<SocketService>();
  final RxList<QuickOrder> quickOrderQueue = <QuickOrder>[].obs;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  final RxString error = ''.obs;

  // 추가: 현재 활성 비즈니스 데이 ID를 저장할 변수
  // Rx<String?> currentBusinessDayId = Rx<String?>(null);
// 주석: _orders를 _quickOrders로 변경
  // final RxList<QuickOrder> _quickOrders = <QuickOrder>[].obs;
  final RxList<QuickOrder> quickOrders = <QuickOrder>[].obs;
  SocketService get _socketService {
    return Get.find<SocketService>();
  }

  @override
  void onInit() {
    super.onInit();

    ever(_authController.restaurantToken, (_) => _onTokenChanged);
  }

  void _onTokenChanged(String? token) {
    if (token != null && token.isNotEmpty) {
      quickFetchOrders();
    } else {
      quickOrders.clear();
    }
  }

// 'completed' 상태가 아닌 주문만 반환하는 계산된 속성
  List<QuickOrder> get activeOrders =>
      quickOrders.where((order) => order.status != 'completed').toList();

  // void clearAllData() {
  //   quickOrderQueue.clear();
  //   isLoading.value = false;
  //   error.value = '';
  //   // currentBusinessDayId.value = null; // 추가: 비즈니스 데이 ID 초기화
  // }

// 주석: handleNewQuickOrder 메서드 추가
  void handleNewQuickOrder(dynamic data) {
    print("New quick order received in controller: $data");
    try {
      final newQuickOrder = QuickOrder.fromJson(data);

      if (_isDuplicateOrder(newQuickOrder)) {
        print("Duplicate quick order detected. Ignoring...");
        return;
      }
      update();
      _processQuickOrder(newQuickOrder);
    } catch (e) {
      print("Error handling new quick order: $e");
      Get.snackbar('오류', '새 퀵오더를 처리하는 중 오류가 발생했습니다.');
    }
  }

  bool _isDuplicateOrder(QuickOrder newQuickOrder) {
    return quickOrders.any((order) =>
        order.id == newQuickOrder.id ||
        (order.createdAt.difference(newQuickOrder.createdAt).abs().inSeconds <
                5 &&
            order.totalAmount == newQuickOrder.totalAmount));
  }

  void _processQuickOrder(QuickOrder newQuickOrder) {
    quickOrders.add(newQuickOrder);
    quickOrders.refresh(); // 리스트의 변경을 GetX에 알립니다
    _audioService.playOrderSound(); // 새 주문이 있을 때 소리 재생
    String message = '새로운 퀵오더가 접수되었습니다. 주문번호: ${newQuickOrder.orderNumber}';
    Get.snackbar('새로운 퀵오더', message, snackPosition: SnackPosition.BOTTOM);

    print(
        "Quick order processed. Current quick order count: ${quickOrders.length}");
  }

  Future<List<QuickOrder>> quickFetchOrders() async {
    if (!_authController.isLoggedIn) {
      print("User is not logged in. Skipping fetch.");
      return [];
    }

    _isLoading.value = true;
    error.value = '';

    try {
      final response = await _apiProvider.get(
        '/api/quick-orders',
        queryParameters: {
          'restaurantId': _authController.restaurant.value?.restaurantId,
        },
      );

      if (response.statusCode == 200) {
        print("API Response: ${response.data}");

        final responseData = response.data as Map<String, dynamic>;

        if (responseData['status'] == 'no_active_business_day') {
          print('No active business day found.');
          return [];
        }

        if (responseData['success'] == true && responseData['data'] is List) {
          final quickOrdersList = responseData['data'] as List;
          final fetchedQuickOrders = quickOrdersList
              .map((orderJson) {
                try {
                  return QuickOrder.fromJson(orderJson);
                } catch (e) {
                  print('Error parsing quick order: $e');
                  return null;
                }
              })
              .whereType<QuickOrder>()
              .toList();

          quickOrders.assignAll(fetchedQuickOrders);
          quickOrders.refresh(); // UI 업데이트를 위해 추가

          quickInitializeOrderQueue(fetchedQuickOrders);
          await quickFetchTodaySales();

          print("Fetched ${quickOrders.length} quick orders");
          return fetchedQuickOrders;
        } else {
          throw Exception("Invalid response format or no data available");
        }
      } else {
        throw Exception(
            "Failed to fetch Quick orders: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error in quickFetchOrders: $e");
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load quick orders');
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  // Future<void> _checkAndStartBusinessDay() async {
  //   try {
  //     final response = await _apiProvider.post(
  //       '/api/business-day/check-and-start',
  //       {
  //         'restaurantId': _authController.restaurant.value?.restaurantId,
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print("Business day checked and started successfully");
  //       // 추가: 비즈니스 데이 ID 저장
  //       // currentBusinessDayId.value = response.data['businessDayId'];
  //     } else {
  //       throw Exception("Failed to check and start business day");
  //     }
  //   } catch (e) {
  //     print("Error in _checkAndStartBusinessDay: $e");
  //   }
  // }

  void quickInitializeOrderQueue(List<QuickOrder> orders) {
    quickOrderQueue.assignAll(orders);
    quickReorderQueue();
  }

  void quickReorderQueue() {
    quickOrderQueue.sort((a, b) {
      if (a.status == 'completed' && b.status != 'completed') return 1;
      if (a.status != 'completed' && b.status == 'completed') return -1;
      if (a.status == 'completed' && b.status == 'completed') return 0;
      return a.orderNumber!.compareTo(b.orderNumber!);
    });

    int position = 1;
    for (var order in quickOrderQueue) {
      if (order.status != 'completed') {
        order.queuePosition = position++;
      }
    }
    update();
  }

  Future<void> quickFetchTodaySales() async {
    try {
      await _salesController
          .fetchTodaySales(_authController.restaurant.value?.restaurantId);
    } catch (e) {
      print("Error fetching today's sales: $e");
    }
  }

  void quickAddToOrderQueue(QuickOrder order) {
    print('Adding new quick order to queue: $order');
    quickOrderQueue.add(order);
    quickReorderQueue();
    update();
    Get.snackbar('Info', '새로운 주문이 접수되었습니다. 주문번호: ${order.orderNumber}');
  }

  void addNewOrder(QuickOrder newOrder) {
    quickOrderQueue.add(newOrder);
    quickReorderQueue();
  }

  Future<void> quickHandleOrderStatusChange(
      String orderId, String currentStatus) async {
    String newStatus = _getNextStatus(currentStatus);
    print('Changing order status from $currentStatus to $newStatus');
    try {
      // preparing -> served 상태 변경 시 푸시 알림 전송
      if (currentStatus == 'preparing' && newStatus == 'served') {
        print('Sending pickup notification...');
        final order = quickOrders.firstWhere((order) => order.id == orderId);

        final orderDetails = order.items
            .map((item) => '${item.name} ${item.quantity}개')
            .join(', ');

        print('Order details for notification: $orderDetails');
        print('User ID: ${order.user}');
        print(
            'Restaurant ID: ${_authController.restaurant.value?.restaurantId}');

        // 푸시 알림 전송
        try {
          await _socketService.sendPickupReadyNotification(
            orderId: orderId,
            userId: order.user,
            restaurantId: _authController.restaurant.value?.restaurantId ?? '',
            businessName: _authController.restaurant.value?.businessName ?? '',
            message: '주문하신 음식이 준비되었습니다. 카운터에서 수령해주세요.',
            orderNumber: order.orderNumber.toString(),
            orderDetails: orderDetails,
          );
          print('Pickup notification sent successfully');
        } catch (notificationError) {
          print('Error sending pickup notification: $notificationError');
        }
      }

      // 상태 업데이트 API 호출
      final response = await _apiProvider.patch(
        '/api/quick-orders',
        {
          'orderId': orderId,
          'newStatus': newStatus,
        },
      );

      if (response.statusCode == 200) {
        final updatedOrder =
            QuickOrder.fromJson(response.data['data']['order']);
        _updateOrderInQuickOrders(updatedOrder);
        _updateOrderInQueue(updatedOrder);

        if (newStatus == 'completed') {
          quickRemoveFromQueue(orderId);
        }

        recalculateQueuePositions();
        await Get.find<SalesController>().fetchTodaySales(
            Get.find<AuthController>().restaurant.value?.restaurantId);

        if (response.data['meta']?['businessDayId'] != null) {
          Get.find<BusinessDayController>().currentBusinessDayId.value =
              response.data['meta']['businessDayId'];
        }

        update();
      } else {
        throw Exception("Failed to update order status");
      }
    } catch (e) {
      print('Error in quickHandleOrderStatusChange: $e');
      error.value = ErrorHandler.handleError(e);
      Get.snackbar('오류', '주문 상태 업데이트에 실패했습니다: ${error.value}');
    }
  }

  void _updateOrderInQuickOrders(QuickOrder updatedOrder) {
    final index =
        quickOrders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      quickOrders[index] = updatedOrder;
      quickOrders.refresh();
    }
  }

  void _updateOrderInQueue(QuickOrder updatedOrder) {
    final index =
        quickOrderQueue.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      quickOrderQueue[index] = updatedOrder;
      quickOrderQueue.refresh();
    }
  }

  void recalculateQueuePositions() {
    quickOrderQueue.sort((a, b) {
      if (a.status == 'completed' && b.status != 'completed') return 1;
      if (a.status != 'completed' && b.status == 'completed') return -1;
      return a.orderNumber!.compareTo(b.orderNumber!);
    });

    int position = 1;
    for (var order in quickOrderQueue) {
      if (order.status != 'completed') {
        order.queuePosition = position++;
      }
    }
    quickOrderQueue.refresh();
    update();
  }

  void quickUpdateOrderStatus(String orderId, String newStatus) {
    final index = quickOrderQueue.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      quickOrderQueue[index] =
          quickOrderQueue[index].copyWith(status: newStatus);
      recalculateQueuePositions();
    }
  }

  void quickRemoveFromQueue(String orderId) {
    quickOrderQueue.removeWhere((order) => order.id == orderId);
    recalculateQueuePositions();
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

  String quickFormatNumber(num number) {
    return NumberFormat('#,###').format(number);
  }

  String quickGetStatusColor(String status) {
    switch (status) {
      case "pending":
        return 'red';
      case "preparing":
        return 'yellow';
      case "served":
        return 'blue';
      case "completed":
        return 'green';
      default:
        return 'grey';
    }
  }

  String quickGetStatusText(String status) {
    switch (status) {
      case "pending":
        return "주문접수";
      case "preparing":
        return "준비중";
      case "served":
        return "서빙완료";
      case "completed":
        return "완료";
      default:
        return "알 수 없음";
    }
  }
}
