//file: \flutter_client\lib\app\modules\admin\admin_order\admin_order_binding.dart

import 'package:get/get.dart';
import './admin_order_controller.dart';
import '../../../controllers/table_controller.dart';
import '../../../controllers/order_controller.dart';
// import '../../../controllers/auth_controller.dart';
// import '../../../controllers/sales_controller.dart';
// import '../../../controllers/order_queue_controller.dart';

class AdminOrderBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AdminOrderController>(() => AdminOrderController());
    // Get.lazyPut(() => TableController());
    // Get.lazyPut(() => OrderController());
    // Get.lazyPut(() => AuthController());
    // Get.lazyPut(() => SalesController());
    // Get.lazyPut(() => OrderQueueController()); // 추가: OrderQueueController 등록
    Get.put(TableController());
    Get.put(OrderController());
  }
}
