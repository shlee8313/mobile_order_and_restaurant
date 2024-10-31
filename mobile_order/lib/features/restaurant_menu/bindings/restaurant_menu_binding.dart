// lib/features/restaurant_menu/bindings/restaurant_menu_binding.dart
import 'package:get/get.dart';
// import 'package:mobile_order/features/restaurant_menu/controllers/quick_order_controller.dart';
import '../controllers/restaurant_menu_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/quick_order_controller.dart';

class RestaurantMenuBinding extends Bindings {
  @override
  void dependencies() {
    final String restaurantId = Get.arguments['restaurantId'];
    final String? tableId = Get.arguments['tableId'];
    Get.lazyPut(() => RestaurantMenuController(
          restaurantId: Get.arguments['restaurantId'],
          tableId: Get.arguments['tableId'],
        ));
    // Inject OrderController
    Get.lazyPut(() => OrderController(restaurantId: restaurantId));
    Get.lazyPut(() => QuickOrderController(restaurantId: restaurantId));
  }
}
