//file: \flutter_client\lib\app\modules\admin\admin_order\admin_order_controller.dart



// import 'package:get/get.dart';
// import '../../../controllers/table_controller.dart';
// import '../../../controllers/order_controller.dart';
// import '../../../controllers/auth_controller.dart';
// import '../../../controllers/sales_controller.dart';
// import '../../../controllers/order_queue_controller.dart';
// import '../../../data/models/table_model.dart';
// import '../../../data/models/order.dart';

// class AdminOrderController extends GetxController {
//   late final TableController tableController;
//   late final OrderController orderController;
//   late final AuthController authController;
//   late final SalesController salesController;
//   late final OrderQueueController orderQueueController;

//   final RxBool _isLoading = true.obs;
//   bool get isLoading => _isLoading.value;

//   final RxMap<int, int> _activeTabsState = <int, int>{}.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     print('AdminOrderController: onInit called');

//     try {
//       tableController = Get.find<TableController>();
//       orderController = Get.find<OrderController>();
//       authController = Get.find<AuthController>();
//       salesController = Get.find<SalesController>();
//       orderQueueController = Get.find<OrderQueueController>();
//     } catch (e) {
//       print('Error initializing controllers: $e');
//       // 필요한 경우 여기서 컨트롤러를 수동으로 초기화할 수 있습니다.
//       // 예: Get.put(OrderQueueController());
//     }

//     fetchTablesAndOrders();
//   }

//   Future<void> fetchTablesAndOrders() async {
//     try {
//       _isLoading.value = true;
//       await tableController.fetchTablesAndOrders();
//       _isLoading.value = false;
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to load tables and orders');
//     }
//   }

//   void handleUpdateTable(int tableId, Map<String, dynamic> newProps) {
//     tableController.updateTable(tableId, newProps);
//   }

//   Future<void> handleSaveLayout(List<TableModel> newTables) async {
//     try {
//       await tableController.saveLayout(newTables);
//       Get.snackbar('Success', 'Table layout saved successfully');
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to save table layout: $error');
//     }
//   }

//   Future<void> handleOrderStatusChange(int tableId, Order order) async {
//     try {
//       await orderController.changeOrderStatus(order.id, order.status);
//       await tableController.fetchTablesAndOrders();
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to update order status: $error');
//     }
//   }

//   Future<void> handlePayment(int tableId) async {
//     try {
//       final ordersToComplete =
//           orderController.orders.where((o) => o.tableId == tableId).toList();
//       for (var order in ordersToComplete) {
//         await orderController.changeOrderStatus(order.id, 'completed');
//       }
//       await tableController.fetchTablesAndOrders();
//       Get.snackbar('Success', 'All orders for table $tableId completed');
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to complete orders: $error');
//     }
//   }

//   Future<void> handleCallComplete(int tableId, Order order) async {
//     try {
//       await orderController.changeOrderStatus(order.id, 'completed');
//       await tableController.fetchTablesAndOrders();
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to complete call: $error');
//     }
//   }

//   int getActiveTab(int tableId) {
//     return _activeTabsState[tableId] ?? 0;
//   }

//   void handleTabChange(int tableId, int tabIndex) {
//     _activeTabsState[tableId] = tabIndex;
//   }

//   String formatNumber(num number) {
//     return number.toStringAsFixed(2).replaceAllMapped(
//         RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
//   }
// }
