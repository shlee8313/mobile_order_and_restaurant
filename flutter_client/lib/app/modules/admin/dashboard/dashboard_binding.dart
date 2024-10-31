// file: lib/app/modules/admin/admin/admin_binding.dart

import 'package:get/get.dart';
import '../../../controllers/sidebar_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../controllers/sales_controller.dart';
import "../../../controllers/auth_controller.dart";
import "../../../controllers/table_controller.dart";
import "../../../controllers/order_controller.dart";
import "../../../controllers/order_queue_controller.dart";
import "../../../controllers/quick_order_controller.dart";

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => TableController());
    Get.lazyPut(() => OrderController());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => SalesController());
    Get.lazyPut(() => OrderQueueController());
  }
}
