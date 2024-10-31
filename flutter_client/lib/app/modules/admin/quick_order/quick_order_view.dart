//file: \flutter_client\lib\app\modules\admin\quick_order\quick_order_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/quick_order_controller.dart';
import '../../../controllers/sales_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/quick_orders.dart';
import '../../../controllers/business_day_controller.dart';

class QuickOrderView extends GetView<QuickOrderController> {
  final SalesController salesController = Get.find<SalesController>();
  final AuthController authController = Get.find<AuthController>();
  final BusinessDayController businessDayController =
      Get.find<BusinessDayController>();
  QuickOrderView({Key? key}) : super(key: key) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInitialData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
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

        return RefreshIndicator(
          onRefresh: _fetchInitialData,
          child: Column(
            children: [
              // _buildTodaySales(),
              Expanded(child: _buildOrderQueue()),
            ],
          ),
        );
      }), // 여기서 Obx()를 닫음
    );
  }

  // Widget _buildTodaySales() {
  //   return Obx(() => Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Text(
  //           '오늘의 매출: ${NumberFormat('#,###').format(salesController.todaySales?.totalSales ?? 0)}원',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //       ));
  // }

  Widget _buildOrderQueue() {
    return Obx(() {
      if (controller.isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.error.isNotEmpty) {
        return Center(child: Text('오류: ${controller.error.value}'));
      }
      final orders = controller.activeOrders; // activeOrders 사용
      if (orders.isEmpty) {
        return Center(child: Text('주문이 없습니다.'));
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio:
                  (constraints.maxWidth / 5) / (constraints.maxHeight / 3),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderCard(orders[index]),
          );
        },
      );
    });
  }

  Widget _buildOrderCard(QuickOrder order) {
    return Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '주문번호: ${order.orderNumber}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                      '대기: ${order.status != 'completed' ? order.queuePosition : '-'}',
                      style: TextStyle(fontSize: 9)),
                  // _buildStatusChip(order.status),
                ],
              ),
              SizedBox(height: 2),
              // Text(
              //     '대기순서: ${order.status != 'completed' ? order.queuePosition : '-'}'),
              Divider(),
              Expanded(
                child: ListView(
                  children: order.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.name} x${item.quantity}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                if (item.selectedOptions.isNotEmpty) ...[
                                  ...item.selectedOptions
                                      .map((option) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 1),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 3,
                                                  height: 3,
                                                  margin:
                                                      EdgeInsets.only(right: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[400],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '${option.name}: ${option.choice}'
                                                    '${option.price > 0 ? ' (+${NumberFormat('#,###').format(option.price)}원)' : ''}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[700],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '총액: ${NumberFormat('#,###').format(order.totalAmount)}원',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleOrderStatusChange(order),
                    child: Text(_getNextStatusButtonText(order.status)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(order.status),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(_getStatusText(status),
          style: TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: _getStatusColor(status),
      padding: EdgeInsets.all(4),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '주문접수';
      case 'preparing':
        return '준비중';
      case 'served':
        return '서빙완료';
      case 'completed':
        return '완료';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'preparing':
        return Colors.orange;
      case 'served':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getNextStatusButtonText(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return '주문접수';
      case 'preparing':
        return '준비중';
      case 'served':
        return '서빙완료';
      case 'completed':
        return '완료됨';
      default:
        return '상태 변경';
    }
  }

  void _handleOrderStatusChange(QuickOrder order) async {
    if (order.status == 'completed')
      return; // No status change allowed if already completed

    try {
      // Send PATCH request to update order status
      await controller.quickHandleOrderStatusChange(order.id, order.status);

      // Fetch updated data
      await salesController
          .fetchTodaySales(authController.restaurant.value?.restaurantId);

      // Optionally, fetch orders again if needed
      // await controller.quickFetchOrders();
    } catch (error) {
      Get.snackbar('오류', '주문 상태 업데이트에 실패했습니다: $error');
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      await controller.quickFetchOrders();
      await salesController
          .fetchTodaySales(authController.restaurant.value?.restaurantId);
    } catch (error) {
      Get.snackbar('오류', '데이터를 가져오는 중 오류가 발생했습니다: $error');
    }
  }
}
