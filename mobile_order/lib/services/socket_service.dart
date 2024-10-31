// file: lib/services/socket_service.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/config/api_config.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart'; // 추가: FCM import
import 'package:audioplayers/audioplayers.dart';
import '../features/order_complete/views/order_complete_page.dart';
import '../services/fcm_service.dart';

class SocketService extends GetxService {
  IO.Socket? socket;
  final FCMService _fcmService = Get.find<FCMService>();
  final RxBool isConnected = false.obs;
  String? _restaurantId;
  String? _connectionType;
  String? _token;
  // final Rx<String?> _fcmToken = Rx<String?>(null); // 추가: FCM 토큰 저장 변수

  // 추가: FCM 토큰 getter
  // String? get fcmToken => _fcmToken.value;
  // final AudioPlayer audioPlayer = AudioPlayer(); // 추가
  // 추가: FCM 초기화 함수
  // Future<void> initFCM() async {
  //   try {
  //     await FirebaseMessaging.instance.requestPermission(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //       provisional: false,
  //     );

  //     _fcmToken.value = await FirebaseMessaging.instance.getToken();
  //     print('FCM Token initialized: ${_fcmToken.value}');

  //     // FCM 토큰 갱신 리스너
  //     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  //       print('FCM Token refreshed: $newToken');
  //       _fcmToken.value = newToken;
  //       if (isConnected.value) {
  //         _updateFCMToken();
  //       }
  //     });

  //     // 포그라운드 메시지 핸들러
  //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //       print('Received FCM foreground message: ${message.data}');

  //       if (message.notification != null) {
  //         print(
  //             'FCM notification: ${message.notification?.title} - ${message.notification?.body}');

  //         // Get.snackbar(
  //         //   message.notification?.title ?? '주문 알림',
  //         //   message.notification?.body ?? '주문이 준비되었습니다.',
  //         //   backgroundColor: Colors.black87,
  //         //   colorText: Colors.white,
  //         //   duration: Duration(seconds: 5),
  //         //   snackPosition: SnackPosition.TOP,
  //         //   margin: EdgeInsets.all(8),
  //         //   borderRadius: 8,
  //         // );
  //       }
  //     });
  //   } catch (e) {
  //     print('Error initializing FCM: $e');
  //   }
  // }

  // // 추가: FCM 토큰 업데이트 함수
  // Future<void> _updateFCMToken() async {
  //   try {
  //     if (_fcmToken.value != null && isConnected.value) {
  //       await emit('updateFCMToken', {
  //         'fcmToken': _fcmToken.value,
  //         'userId': _token,
  //         'restaurantId': _restaurantId,
  //       });
  //     }
  //   } catch (e) {
  //     print('Error updating FCM token: $e');
  //   }
  // }

  Future<void> connect(String restaurantId, String connectionType,
      {String? token}) async {
    _restaurantId = restaurantId;
    _connectionType = connectionType;
    _token = token;
    // await initFCM(); // 추가: FCM 초기화
    await _initSocket();
  }

  Future<void> _initSocket() async {
    print('Connecting to socket server...');
    print('Restaurant ID: $_restaurantId');
    print('Connection Type: $_connectionType');
    print('Token: ${_token != null ? 'Provided' : 'Not provided'}');

    socket = IO.io(ApiConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {
        'restaurantId': _restaurantId,
        'connectionType': _connectionType,
        'fcmToken': _fcmService.fcmToken, // 추가: FCM 토큰 전달
        if (_token != null) 'token': _token,
      },
    });

    socket!.connect();
    _setupSocketListeners(); // 추가: 소켓 리스너 설정 함수 호출
    await _waitForConnection();
  }

  Future<void> _updateFCMToken() async {
    try {
      if (_fcmService.fcmToken != null && isConnected.value) {
        await emit('updateFCMToken', {
          'fcmToken': _fcmService.fcmToken,
          'userId': _token,
          'restaurantId': _restaurantId,
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // 추가: 소켓 리스너 설정 함수
  void _setupSocketListeners() {
    socket!.on('connect', (_) async {
      print('Connected to socket server');
      isConnected.value = true;
      await _refreshToken();
      await _updateFCMToken(); // 추가: 연결 시 FCM 토큰 업데이트
    });

    socket!.on('disconnect', (_) {
      print('Disconnected from socket server');
      isConnected.value = false;
      _reconnect();
    });

    socket!.on('error', (error) {
      print('Socket error: $error');
      isConnected.value = false;
      _reconnect();
    });

    socket!.on('pickupReady', (data) async {
      print('Pickup ready socket event received with data: $data');
      print('Pickup ready socket event received with data: $data'); // 전체 데이터 로그
      print('Restaurant ID: ${data['restaurantId']}'); // 식당 ID 로그 추가
      print('Business Name: ${data['businessName']}'); // 식당 이름 로그 추가

      try {
        // 알림음 재생
        // await audioPlayer.play(AssetSource('sounds/ding_dong.mp3'));
        // 소켓 알림 표시
        // 주문완료 페이지로 이동
        Get.toNamed('/order_complete', arguments: {
          'restaurantId': data['restaurantId'] ?? '',
          'businessName': data['businessName'] ?? '', // businessName으로 수정
          'orderNumber': data['orderNumber']?.toString() ?? '',
          'orderDetails': data['orderDetails'] ?? '',
        });
        // Get.snackbar(
        //   '주문 완료',
        //   data['message'] ?? '주문하신 음식이 준비되었습니다. 카운터에서 수령해주세요.',
        //   backgroundColor: Colors.black87,
        //   colorText: Colors.white,
        //   duration: Duration(seconds: 5),
        //   snackPosition: SnackPosition.TOP,
        //   margin: EdgeInsets.all(8),
        //   borderRadius: 8,
        // );
      } catch (e) {
        print('Error showing snackbar: $e');
      }
    });
  }

  Future<void> _waitForConnection() async {
    int attempts = 0;
    while (!isConnected.value && attempts < 5) {
      await Future.delayed(Duration(seconds: 1));
      attempts++;
    }
    if (!isConnected.value) {
      throw Exception('Failed to connect to socket server after 5 attempts');
    }
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 5), () {
      if (!isConnected.value) {
        print('Attempting to reconnect...');
        _initSocket();
      }
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
    isConnected.value = false;
    print('Socket disconnected and reset');
  }

  Future<void> emit(String event, dynamic data,
      [Function(dynamic)? ack]) async {
    await ensureConnection();
    if (isConnected.value && socket != null) {
      if (ack != null) {
        socket!.emitWithAck(event, data, ack: (resp) {
          ack(resp);
        });
      } else {
        socket!.emit(event, data);
      }
    } else {
      throw Exception('Failed to emit event: $event. Socket is not connected.');
    }
  }

  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  void off(String event) {
    socket?.off(event);
  }

  Future<Map<String, dynamic>> sendNewOrder(
      Map<String, dynamic> orderData) async {
    try {
      print('Socket Service sending order data: $orderData');
      await ensureConnection();
      Completer<Map<String, dynamic>> completer = Completer();
      // isQuickOrder 플래그를 명시적으로 false로 설정
      orderData['isQuickOrder'] = false;

      await emit('newOrder', orderData, (response) {
        if (response is Map<String, dynamic> && response['success'] == true) {
          completer.complete(
              {'success': true, 'message': 'Order sent successfully'});
        } else {
          completer.complete(
              {'success': false, 'message': 'Failed to send order via socket'});
        }
      });

      return await completer.future;
    } catch (e) {
      return {'success': false, 'message': 'Error sending order: $e'};
    }
  }

  Future<Map<String, dynamic>> sendNewQuickOrder(
      Map<String, dynamic> orderData) async {
    try {
      print('Socket Service sending quick order data: $orderData');
      await ensureConnection();
      Completer<Map<String, dynamic>> completer = Completer();
      // isQuickOrder 플래그를 명시적으로 true로 설정
      orderData['isQuickOrder'] = true;
      orderData['fcmToken'] = _fcmService.fcmToken;
      await emit('newQuickOrder', orderData, (response) {
        if (response is Map<String, dynamic> && response['success'] == true) {
          completer.complete(
              {'success': true, 'message': 'Quick order sent successfully'});
        } else {
          completer.complete({
            'success': false,
            'message': 'Failed to send quick order via socket'
          });
        }
      });

      return await completer.future;
    } catch (e) {
      return {'success': false, 'message': 'Error sending quick order: $e'};
    }
  }

  void listenForNewOrders(String restaurantId, Function(dynamic) handler) {
    on('newOrder', handler);
    on('newQuickOrder', handler);
  }

  Future<void> ensureConnection() async {
    if (!isConnected.value || socket == null) {
      print('Socket is not connected. Attempting to reconnect...');
      await _initSocket();
      await _waitForConnection();
    }
  }

  Future<void> _refreshToken() async {
    // TODO: 실제 토큰 갱신 로직 구현
    print('Token refreshed');
  }
}
