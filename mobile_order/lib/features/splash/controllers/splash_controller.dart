// lib/features/splash/controllers/splash_controller.dart

import 'package:get/get.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 앱 초기화에 필요한 작업들을 여기서 수행
      await Future.delayed(Duration(seconds: 2)); // 최소 스플래시 표시 시간

      // 로그인 상태에 따라 적절한 화면으로 이동
      if (_authController.isLoggedIn) {
        Get.offNamed('/home');
      } else {
        Get.offNamed('/login');
      }
    } catch (e) {
      print('Error initializing app: $e');
      // 에러 처리
      Get.offNamed('/login');
    }
  }
}
