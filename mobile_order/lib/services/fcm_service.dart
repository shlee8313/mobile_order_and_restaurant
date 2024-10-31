// file: lib/services/fcm_service.dart
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase import 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChannels용
import 'dart:convert';
import './audio_service.dart';

class FCMService extends GetxService {
  final Rx<String?> _fcmToken = Rx<String?>(null);
  String? get fcmToken => _fcmToken.value;
  final AudioService _audioService = Get.find<AudioService>();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<FCMService> init() async {
    try {
      await _requestPermission();
      await _initializeToken();
      await _initializeNotifications();
      _setupTokenRefresh();
      _setupMessageHandlers();
      _setupAppLifecycleListener(); // 추가
      return this;
    } catch (e) {
      print('Error initializing FCM Service: $e');
      return this;
    }
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('FCM Authorization status: ${settings.authorizationStatus}');
  }

  Future<void> _initializeToken() async {
    _fcmToken.value = await FirebaseMessaging.instance.getToken();
    print('FCM Token initialized: ${_fcmToken.value}');
  }

  void _setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      _fcmToken.value = newToken;
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        if (details.payload != null) {
          final payloadData =
              Map<String, dynamic>.from(json.decode(details.payload!) as Map);
          _navigateToOrderComplete(payloadData);
        }
      },
    );

    // 알림 채널 생성
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_ready_channel',
      'Order Notifications',
      description: 'This channel is used for order notifications.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('ding_dong'),
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _setupMessageHandlers() {
    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 핸들러
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 앱이 종료된 상태에서 알림을 탭하여 열었을 때
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);

    // 백그라운드 상태에서 알림을 탭하여 열었을 때
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 알림 표시 옵션 설정
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.data['type'] == 'pickup_ready') {
      try {
        // 포그라운드에서는 AudioService로 직접 재생
        _audioService.playOrderSound();
        await _showLocalNotification(message);
        _navigateToOrderComplete(message.data);
        // 기존 알림 모두 제거
        await _flutterLocalNotificationsPlugin.cancelAll();

        // 또는 특정 ID의 알림만 제거하려면:
        // await _flutterLocalNotificationsPlugin.cancel(message.hashCode);
      } catch (e) {
        print('Error handling foreground message: $e');
      }
    }
  }

  Future<void> _handleInitialMessage(RemoteMessage? message) async {
    if (message != null && message.data['type'] == 'pickup_ready') {
      _navigateToOrderComplete(message.data);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (message.data['type'] == 'pickup_ready') {
      _navigateToOrderComplete(message.data);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        '주문 완료',
        message.data['orderDetails'] ?? '주문하신 메뉴가 준비되었습니다',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'order_ready_channel',
            'Order Notifications',
            channelDescription: 'This channel is used for order notifications.',
            importance: Importance.high,
            priority: Priority.high,
            sound: const RawResourceAndroidNotificationSound('ding_dong'),
            playSound: true,
            autoCancel: true, // 알림 탭했을 때 자동으로 제거
          ),
        ),
        payload: json.encode(message.data),
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  void _navigateToOrderComplete(Map<String, dynamic> data) {
    // 현재 OrderCompletePage가 이미 열려있는지 확인
    if (Get.currentRoute == '/order_complete') {
      // 이미 OrderCompletePage가 열려있다면 닫고 새로 열기
      Get.back();
    }

    Get.toNamed('/order_complete', arguments: {
      'businessName': data['businessName'],
      'restaurantId': data['restaurantId'],
      'orderNumber': data['orderNumber'] ?? '',
      'orderDetails': data['orderDetails'] ?? '',
    });

    // 알림 제거
    _flutterLocalNotificationsPlugin.cancelAll();
  }

// 앱이 백그라운드에서 포그라운드로 전환될 때 알림 제거
  void _setupAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        // 앱이 포그라운드로 돌아올 때 모든 알림 제거
        await _flutterLocalNotificationsPlugin.cancelAll();
      }
      return null;
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// 백그라운드 메시지 핸들러는 top-level function이어야 합니다
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data['type'] == 'pickup_ready') {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // 알림 채널을 다시 생성하지 않고 기존 채널 사용
    try {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        '주문 완료',
        message.data['orderDetails'] ?? '주문하신 메뉴가 준비되었습니다',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'order_ready_channel',
            'Order Notifications',
            channelDescription: 'This channel is used for order notifications.',
            importance: Importance.high,
            priority: Priority.high,
            sound: const RawResourceAndroidNotificationSound('ding_dong'),
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    } catch (e) {
      print('Error showing background notification: $e');
      print(e.toString()); // 상세 에러 로그
    }
  }
}
