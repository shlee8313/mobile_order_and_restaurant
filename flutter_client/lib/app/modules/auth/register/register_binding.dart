// file: lib/app/modules/auth/register/register_binding.dart

import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/providers/api_provider.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // 기존의 AuthController를 찾아서 사용
    Get.find<AuthController>();

    // ApiProvider가 아직 초기화되지 않았다면 초기화
    if (!Get.isRegistered<ApiProvider>()) {
      Get.put(ApiProvider());
    }
  }
}
