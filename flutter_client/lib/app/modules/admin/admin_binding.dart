// file: lib/app/modules/admin/admin_binding.dart

import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/sidebar_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/sales_controller.dart';
import '../../controllers/table_controller.dart';
import '../../controllers/quick_order_controller.dart';
import "../../controllers/order_queue_controller.dart";
import "../../controllers/auth_controller.dart";
import "./admin_controller.dart";

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // 관리자 섹션에서 사용되는 컨트롤러들을 초기화합니다.
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<SidebarController>(() => SidebarController());
    // Get.lazyPut<OrderController>(() => OrderController());
    // Get.lazyPut<SalesController>(() => SalesController());
    // Get.lazyPut<TableController>(() => TableController());
    // Get.lazyPut<OrderQueueController>(() => OrderQueueController());
    // Get.lazyPut<QuickOrderQueueController>(() => QuickOrderQueueController());

    // 필요에 따라 더 많은 컨트롤러들을 여기에 추가할 수 있습니다.
  }
}
