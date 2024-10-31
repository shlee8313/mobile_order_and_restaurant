//file: \flutter_client\lib\app\modules\auth\login\login_binding.dart

import 'package:get/get.dart';
import 'login_controller.dart';
// import '../../../data/providers/auth_api.dart';
import '../../../controllers/auth_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    // Get.lazyPut(() => AuthApi());
    Get.lazyPut(() => LoginController());
  }
}
