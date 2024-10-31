//file: \flutter_client\lib\app\data\services\socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/quick_order_controller.dart';
import '../../controllers/auth_controller.dart';

class SocketService extends GetxService {
  IO.Socket? socket;
  OrderController? orderController;
  QuickOrderController? quickOrderController;
  late final bool hasTables;
  bool _isListenerAttached = false;
  final String restaurantId;
  final RxBool isConnected = false.obs;
  final String? token;
  final bool isAdmin;
  int _reconnectAttempts = 0;
  static const int MAX_RECONNECT_ATTEMPTS = 5;

  SocketService({
    required this.restaurantId,
    this.token,
    required this.isAdmin,
  });

  Future<void> init() async {
    print("SocketService init called for restaurant: $restaurantId");

    try {
      // 레스토랑의 테이블 유무 확인
      final restaurant = Get.find<AuthController>().restaurant.value;
      hasTables = restaurant?.hasTables ?? false;
      print("Restaurant has tables: $hasTables");

      final socketUrl =
          dotenv.env['SOCKET_SERVER_URL'] ?? 'http://localhost:5000';
      print("Socket URL: $socketUrl");

      final Map<String, dynamic> auth = {
        'restaurantId': restaurantId,
        'connectionType': isAdmin ? 'admin' : 'customer',
        'hasTables': hasTables,
      };

      if (isAdmin && token != null) {
        auth['token'] = token;
        print("Added admin token to auth");
      }

      socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': auth,
      });

      _setupSocketListeners();
      socket?.connect();

      // 주석: 연결 상태 확인을 위한 타임아웃 추가
      await Future.delayed(Duration(seconds: 2));
      if (!isConnected.value) {
        print("Socket connection failed to establish in time");
        _reconnect();
      }
    } catch (e) {
      print('Error in SocketService init: $e');
      _reconnect();
    }
  }

  void _setupSocketListeners() {
    socket?.onConnect((_) {
      print(
          'Connected to socket server for restaurant: $restaurantId as ${isAdmin ? 'admin' : 'customer'}');
      isConnected.value = true;
      _reconnectAttempts = 0;
      // 주석: 연결 직후 바로 리스너 설정
      Future.microtask(() => _attachListeners());
    });

    socket?.onDisconnect((_) {
      print('Disconnected from socket server for restaurant: $restaurantId');
      isConnected.value = false;
      _isListenerAttached = false;
    });

    socket?.onConnectError((error) {
      print('Connection error for restaurant $restaurantId: $error');
      isConnected.value = false;
      _isListenerAttached = false;
      _reconnect();
    });

    socket?.onError((error) {
      print('Socket error for restaurant $restaurantId: $error');
      _reconnect();
    });
  }

  void _attachListeners() {
    if (!_isListenerAttached) {
      print("Attaching listeners for ${hasTables ? 'table' : 'quick'} orders");
      print("Restaurant ID: $restaurantId, Has Tables: $hasTables");

      // 주석: 기존 리스너 제거
      socket?.off('newOrder');
      socket?.off('newQuickOrder');

      // 주석: 리스너 설정
      if (!hasTables) {
        socket?.on('newQuickOrder', (data) {
          print("QuickOrder socket event received: $data");
          _handleNewQuickOrder(data);
        });
        print("Attached newQuickOrder listener for restaurant: $restaurantId");
      } else {
        socket?.on('newOrder', (data) {
          print("Order socket event received: $data");
          _handleNewOrder(data);
        });
        print("Attached newOrder listener for restaurant: $restaurantId");
      }

      _isListenerAttached = true;
      print("Listeners attached successfully");
    }
  }

  void _handleNewOrder(dynamic data) {
    if (!hasTables) {
      print('Ignoring newOrder event for restaurant without tables');
      return;
    }

    try {
      print(
          'New order received in SocketService for restaurant $restaurantId: $data');
      if (orderController != null) {
        orderController!.handleNewOrder(data);
      } else {
        print('Warning: OrderController is not set in SocketService');
      }
    } catch (e) {
      print('Error handling new order: $e');
    }
  }

  void _handleNewQuickOrder(dynamic data) {
    if (hasTables) {
      print('Ignoring newQuickOrder event for restaurant with tables');
      return;
    }

    try {
      print(
          'New quick order received in SocketService for restaurant $restaurantId: $data');
      if (quickOrderController != null) {
        quickOrderController!.handleNewQuickOrder(data);
      } else {
        print('Warning: QuickOrderController is not set in SocketService');
      }
    } catch (e) {
      print('Error handling new quick order: $e');
    }
  }

  void setOrderController(OrderController controller) {
    print("Setting OrderController in SocketService");
    orderController = controller;
    print("OrderController set successfully");
  }

  void setQuickOrderController(QuickOrderController controller) {
    print("Setting QuickOrderController in SocketService");
    quickOrderController = controller;
    print("QuickOrderController set successfully");
  }

  Future<void> sendPickupReadyNotification({
    required String orderId,
    required String userId,
    required String restaurantId,
    required String businessName,
    required String message,
    required String orderNumber,
    required String orderDetails,
  }) async {
    try {
      print(
          'Sending pickup ready notification for order: $orderId to user: $userId');
      socket?.emit('sendPickupNotification', {
        'orderId': orderId,
        'userId': userId,
        'restaurantId': restaurantId,
        'businessName': businessName,
        'message': message,
        'orderNumber': orderNumber,
        'orderDetails': orderDetails,
      });
    } catch (e) {
      print('Error sending pickup notification: $e');
    }
  }

  void _reconnect() {
    if (_reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
      Future.delayed(Duration(seconds: 5), () {
        print(
            'Attempting to reconnect for restaurant $restaurantId... (Attempt ${_reconnectAttempts + 1})');
        socket?.connect();
        _reconnectAttempts++;
      });
    } else {
      print(
          'Max reconnection attempts reached for restaurant $restaurantId. Please check your connection and try again later.');
    }
  }

  Future<void> disconnect() async {
    print('Disconnecting socket for restaurant: $restaurantId');
    try {
      socket?.emit('logout', {'restaurantId': restaurantId});
      await Future.delayed(Duration(milliseconds: 500));
      socket?.disconnect();
      socket?.dispose();
      socket = null;
      isConnected.value = false;
      _isListenerAttached = false;
      orderController = null;
      quickOrderController = null;
      print('Socket disconnected successfully');
    } catch (e) {
      print('Error during socket disconnect: $e');
    }
  }

  void reconnect() {
    if (socket != null && !isConnected.value) {
      print('Manually attempting to reconnect for restaurant $restaurantId...');
      _isListenerAttached = false;
      socket!.connect();
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
