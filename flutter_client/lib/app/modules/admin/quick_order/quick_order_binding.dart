// file: \flutter_client\lib/app/modules/quick_order/quick_order_binding.dart

import 'package:get/get.dart';
// import '../../../controllers/order_queue_controller.dart'; // Import OrderQueueController
import '../../../controllers/quick_order_controller.dart';

class QuickOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(QuickOrderController(), permanent: true); // Register the controller
  }
}
