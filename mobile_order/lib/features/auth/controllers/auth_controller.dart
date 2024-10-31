//file: \lib\features\auth\controllers\auth_controller.dart

import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../models/user.dart';
import '../../../navigation/controllers/navigation_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  Rx<User?> get currentUser => _authService.currentUser;
  final NavigationController _navigationController =
      Get.find<NavigationController>();
  bool get isLoggedIn => currentUser.value != null;
  /**
   * 
   */
  @override
  void onInit() {
    super.onInit();
    print('AuthController initialized'); // 로그 추가
    ever(_authService.currentUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    print(
        'Auth state changed: ${user != null ? 'Logged in' : 'Logged out'}'); // 로그 추가
    if (user != null) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  // 로그인 상태를 강제로 초기화하는 메서드
  Future<void> resetLoginState() async {
    await _authService.signOut();
    print('Login state reset');
    // 강제로 로그아웃 상태로 설정
    _authService.currentUser.value = null;
    await Get.offAllNamed('/login');
    print('Login state reset');
  }

  // Rx<User?> get currentUser => _authService.currentUser;

  Future<bool> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<bool> signInWithApple() async {
    return await _authService.signInWithApple();
  }

  Future<void> signOut() async {
    _navigationController.resetNavigation(); // 로그아웃 전에 네비게이션 초기화
    await _authService.signOut();
  }

  Future<bool> updateUser(Map<String, dynamic> userData) async {
    return await _authService.updateUser(userData);
  }

  // bool get isLoggedIn => _authService.isLoggedIn;

  Future<String?> getUserToken() async {
    return await _authService.getUserToken();
  }

  // 새로 추가된 getUserId 메서드
  // Future<String?> getUserId() async {
  //   return await _authService.getUserId();
  // }
}
