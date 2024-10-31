import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order.dart';
import '../../../models/quick_order.dart';

class OrderHistoryBottomSheet extends StatelessWidget {
  final List<dynamic> orders;
  final bool hasTables;
  final String restaurantName;

  const OrderHistoryBottomSheet({
    Key? key,
    required this.orders,
    required this.hasTables,
    this.restaurantName = '', // optional로 변경하고 기본값 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 가격이 0인 주문을 제외한 주문들로 필터링
    final filteredOrders = orders.where((order) {
      if (order is Order) {
        return !order.isComplimentaryOrder && order.totalAmount > 0;
      }
      return true; // QuickOrder의 경우는 모두 포함 (이미 유료주문임)
    }).toList();

    final groupedOrders = _groupOrdersByTable(filteredOrders);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '주문 내역',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '총 ${filteredOrders.length}건',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (filteredOrders.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '주문 내역이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: groupedOrders.length,
                itemBuilder: (context, index) {
                  final tableId = groupedOrders.keys.elementAt(index);
                  final tableOrders = groupedOrders[tableId]!;
                  return _buildTableOrderSection(context, tableId, tableOrders);
                },
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<dynamic>> _groupOrdersByTable(List<dynamic> filteredOrders) {
    final groupedOrders = <String, List<dynamic>>{};
    for (var order in filteredOrders) {
      final tableId =
          hasTables ? (order as Order).tableId.toString() : 'Quick Order';
      if (!groupedOrders.containsKey(tableId)) {
        groupedOrders[tableId] = [];
      }
      groupedOrders[tableId]!.add(order);
    }
    return groupedOrders;
  }

  Widget _buildTableOrderSection(
      BuildContext context, String tableId, List<dynamic> tableOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            hasTables
                ? restaurantName.isNotEmpty
                    ? '$restaurantName - 테이블 $tableId'
                    : '테이블 $tableId'
                : restaurantName.isNotEmpty
                    ? restaurantName
                    : '주문',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 테이블이 없는 경우 주문번호로 정렬하고 표시
        ...(!hasTables
            ? tableOrders
                .map((order) => _buildOrderCard(
                      context,
                      order,
                      showOrderNumber: true, // 주문번호 표시 플래그
                    ))
                .toList()
            : tableOrders
                .map((order) => _buildOrderCard(context, order))
                .toList()),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order,
      {bool showOrderNumber = false}) {
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

    String orderStatus = order.status;
    String orderDate = dateFormatter.format(order.createdAt);
    String totalAmount = formatter.format(order.totalAmount);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    orderStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                if (showOrderNumber) ...[
                  // 주문번호 표시 추가
                  Text(
                    '주문번호: ${order.orderNumber}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  orderDate,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildOrderItemRow(item)).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 금액',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalAmount}원',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(dynamic item) {
    final formatter = NumberFormat('#,###');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${formatter.format(item.price)}원 x ${item.quantity}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${formatter.format(item.price * item.quantity)}원',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
