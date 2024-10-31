//file: lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart'; // 추가
import 'firebase_options.dart';

// View imports
import 'features/home/views/home_page.dart';
import 'features/qr_scanner/views/qr_scanner_page.dart';
import 'features/restaurants_list/views/restaurants_list_page.dart';
import 'features/restaurant_menu/views/restaurant_menu_page.dart';
import 'features/order_list/views/order_list_page.dart';
import 'features/profile/views/profile_page.dart';
import 'features/auth/views/login_page.dart';
import 'features/payment/views/payment_page.dart';
import 'features/order_complete/views/order_complete_page.dart';
// Controller imports
import 'features/auth/controllers/auth_controller.dart';
import 'navigation/controllers/navigation_controller.dart';
import 'features/qr_scanner/controllers/qr_scanner_controller.dart';
import 'features/restaurant_menu/controllers/restaurant_menu_controller.dart';
import 'features/payment/controllers/payment_controller.dart';
import 'features/restaurant_menu/controllers/order_controller.dart';
import 'features/restaurant_menu/controllers/quick_order_controller.dart';
import 'controllers/business_day_controller.dart';
import './features/restaurant_menu/bindings/restaurant_menu_binding.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 추가
import './features/order_complete/controllers/order_complete_controller.dart';
import './features/splash/views/splash_screen.dart';
import './features/splash/bindings/splash_binding.dart';
// Service imports
import './services/auth_service.dart';
import './services/restaurant_service.dart';
import './services/socket_service.dart';
import './services/order_service.dart';
import './services/quick_order_service.dart';
import './services/fcm_service.dart';
import './services/audio_service.dart';
// Utility imports
import 'core/utils/encryption_helper.dart';
import 'core/theme/app_theme.dart';

// Widget imports
import 'navigation/widgets/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Terminated 상태에서의 메시지 처리
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // 앱이 완전히 종료된 상태에서 알림을 통해 열렸을 때
    _handleMessage(initialMessage);
  }
// FCM 권한 요청 및 초기화 추가
  // await _initializeFCM();
// FCM 서비스 초기화
// AudioPlayer 전역 설정
  // AudioCache.instance =
  //     AudioCache(prefix: 'assets/sounds/'); // assets/ 경로를 기본으로 설정

  print('Initializing dependencies');
  await Get.putAsync(() => AudioService().init());
  // FCM 서비스 초기화
  await Get.putAsync(() => FCMService().init());

  final authService = Get.put(AuthService());
  await authService.init();

  // final authService = Get.put(AuthService());
  // await authService.init(); // AuthService 초기화 기다림
  Get.put(NavigationController()); // 이 부분이 중요합니다!
  Get.put(AuthController());
  Get.put(BusinessDayController());
  Get.put(SocketService());
  Get.put(OrderService());
  Get.put(QuickOrderService());

  Get.put(EncryptionHelper());
  Get.put(QrScannerController(Get.find<EncryptionHelper>()));
  // Get.put(OrderController());
  // Get.put(QuickOrderController());
  Get.put(RestaurantService());

  // Get.put(OrderController());
  // Get.put(QuickOrderController());
// final authService = Get.put(AuthService());
  // await authService.init();

  // final authService = Get.put(AuthService());
  // await authService.init();

  // if (authService.isLoggedIn) {
  //   final userId = authService.currentUser.value?.uid;
  //   final token = await authService.getUserToken();

  //   if (userId != null) {
  //     await Get.putAsync(() => SocketService(
  //           userId: userId,
  //           connectionType: 'customer',
  //           token: token,
  //         ).init());
  //   }
  // }
  // 로그인 상태 초기화
  // await authController.resetLoginState();
  runApp(const MyApp());
}

void _handleMessage(RemoteMessage message) {
  if (message.data['type'] == 'pickup_ready') {
    // 지연 처리를 통해 앱 초기화 완료 후 네비게이션 수행
    Future.delayed(Duration(milliseconds: 500), () {
      Get.toNamed('/order_complete', arguments: {
        'businessName': message.data['businessName'],
        'restaurantId': message.data['restaurantId'],
        'orderNumber': message.data['orderNumber'] ?? '',
        'orderDetails': message.data['orderDetails'] ?? '',
      });
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/splash', // 수정된 부분
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
          binding: SplashBinding(),
        ),

        GetPage(name: '/', page: () => InitialPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => MainScreen()),
        GetPage(name: '/qr_scanner', page: () => QrScannerPage()),
        GetPage(name: '/restaurant_list', page: () => RestaurantsListPage()),
        GetPage(name: '/order_list', page: () => OrderListPage()),
        // GetPage(name: '/cart', page: () => CartPage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(
          name: '/restaurant_menu',
          page: () => RestaurantMenuPage(),
          // binding: BindingsBuilder(() {
          //   Get.lazyPut(() => RestaurantMenuController(
          //         restaurantId: Get.arguments['restaurantId'] as String,
          //         tableId: Get.arguments['tableId'] as String?,
          //       ));
          //   Get.put(OrderController(restaurantId: ''), permanent: true);
          //   Get.Put(QuickOrderController(restaurantId: ''), permanent: true);
          // }),
          binding: RestaurantMenuBinding(),
        ),
        GetPage(
          name: '/payment',
          page: () => PaymentPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<PaymentController>(() => PaymentController());
          }),
        ),
        GetPage(
          name: '/order_complete',
          page: () => OrderCompletePage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => OrderCompleteController());
          }),
        )
      ],
      translations: AppTranslations(),
      locale: const Locale('ko', 'KR'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

class InitialPage extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoggedIn) {
        return MainScreen();
      } else {
        return LoginPage();
      }
    });
  }
}

class MainScreen extends GetView<NavigationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.changePage,
        children: [
          HomePage(),
          QrScannerPage(),
          RestaurantsListPage(),
          OrderListPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'home': 'Home',
          'scan': 'Scan',
          'restaurants': 'Restaurants',
          'orders': 'Orders',
          'profile': 'Profile',
        },
        'ko_KR': {
          'home': '홈',
          'scan': '스캔',
          'restaurants': '레스토랑',
          'orders': '주문',
          'profile': '프로필',
        },
      };
}
