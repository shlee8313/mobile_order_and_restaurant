// file: lib/app/modules/admin/admin_order/admin_order_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/table_controller.dart';
import '../../../data/models/order.dart';
import '../../../data/models/table_model.dart';
import '../../../ui/widgets/advanced_table_layout.dart';
import '../../../ui/widgets/restaurant_table.dart';
import '../../../controllers/order_queue_controller.dart';
import 'package:intl/intl.dart';
import '../../../controllers/business_day_controller.dart';

/**
 * 
 */
class AdminOrderView extends GetView<OrderController> {
  final TableController tableController = Get.find<TableController>();
  final OrderController orderController = Get.find<OrderController>();
  final OrderQueueController orderQueueController =
      Get.find<OrderQueueController>();
  final BusinessDayController businessDayController =
      Get.find<BusinessDayController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      if (!businessDayController.isBusinessDayActive.value) {
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   _showBusinessDayEndedDialog(context);
        // });
        return const Center(
          child: Text(
            '현재 영업 마감 중입니다.\n영업을 시작하려면 영업마감 해제 버튼을 눌러주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        );
      }

      return FutureBuilder(
        future: Future.wait([
          orderController.fetchOrders(),
          tableController.fetchTablesAndOrders(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // OrderQueueController 초기화
          Get.find<OrderQueueController>()
              .initializeOrderQueue(orderController.orders);
          return GetBuilder<OrderController>(
            builder: (orderController) {
              return Obx(() {
                if (tableController.tables.isEmpty) {
                  // tableController.createInitialTables();
                  return Center(child: Text('테이블이 없습니다. 테이블을 추가해주세요.'));
                }
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: AdvancedTableLayout(
                          tables: tableController.tables,
                          isEditMode: false,
                          onUpdateTable: (_, __) {}, // 편집 불가능한 빈 함수
                          onSaveLayout: () {}, // 저장 불가능한 빈 함수
                          renderTableContent: (table) => RestaurantTable(
                            table: table,
                            handleOrderStatusChange:
                                controller.updateOrderStatus,
                            handleCallComplete: controller.handleCallComplete,
                            handlePayment: controller.handlePayment,
                            // activeTab: 0,
                            handleTabChange: (_, __) {},
                            orderQueue: controller.orders,
                            formatNumber: _formatNumber,
                            orderQueueController:
                                orderQueueController, // 추가된 부분
                          ),
                          onAddTable: () => TableModel(
                            // 여기를 수정했습니다
                            id: DateTime.now().toString(),
                            tableId: tableController.tables.length + 1,
                            x: 0,
                            y: 0,
                            width: 250,
                            height: 250,
                            status: 'empty',
                          ),
                          onRemoveTable: (_) {}, // 테이블 제거 불가능한 빈 함수
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          );
        },
      );
    }));
  }
  // void _handleCallComplete(int tableId, Order order) {
  //   // Implement call complete logic
  // }

  String _formatNumber(num number) {
    final formatter = NumberFormat('#,##0'); // 3자리마다 콤마
    return formatter.format(number);
  }
}
