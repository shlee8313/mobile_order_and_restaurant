//file: \flutter_client\lib\app\modules\admin\edit_menu\menu_edit_binding.dart

import 'package:get/get.dart';
import '../../../controllers/menu_edit_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/providers/api_provider.dart';

class MenuEditBinding extends Bindings {
  @override
  void dependencies() {
    // ApiProvider 초기화 (아직 초기화되지 않았다면)
    // Get the existing instances of ApiProvider and AuthController
    // ApiProvider apiProvider = Get.find<ApiProvider>();
    // AuthController authController = Get.find<AuthController>();

    print('MenuEditBinding dependencies called');
    Get.lazyPut<MenuEditController>(() => MenuEditController());
  }
}
