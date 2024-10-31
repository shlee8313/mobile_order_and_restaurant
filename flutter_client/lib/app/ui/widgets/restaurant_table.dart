// File: lib/app/ui/widgets/restaurant_table.dart

import 'package:flutter/material.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order.dart';
import '../../controllers/order_queue_controller.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; // 주석: math 패키지 import 추가

class RestaurantTable extends StatefulWidget {
  final TableModel table;
  final Function(int, Order) handleOrderStatusChange;
  final Function(int, Order) handleCallComplete;
  final Function(int) handlePayment;
  final Function(int, int) handleTabChange;
  final List<Order> orderQueue;
  final String Function(num) formatNumber;
  final OrderQueueController orderQueueController;

  const RestaurantTable({
    Key? key,
    required this.table,
    required this.handleOrderStatusChange,
    required this.handleCallComplete,
    required this.handlePayment,
    required this.handleTabChange,
    required this.orderQueue,
    required this.formatNumber,
    required this.orderQueueController,
  }) : super(key: key);

  @override
  _RestaurantTableState createState() => _RestaurantTableState();
}

class _RestaurantTableState extends State<RestaurantTable> {
  int _currentIndex = 0;

  List<Order>? _previousOrders; // 주석: 이전 주문 목록 저장을 위한 변수 추가

  // 주석: 새로운 함수 - 주문 정렬 로직
// 주석: 정렬 로직 수정 - served 주문은 맨 왼쪽, 새 주문은 맨 오른쪽으로 배치
  List<Order> _sortOrders(List<Order> orders) {
    final sorted = List<Order>.from(orders);
    sorted.sort((a, b) {
      // 1. served 주문을 맨 앞으로
      if (a.status == 'served' && b.status != 'served') return -1;
      if (a.status != 'served' && b.status == 'served') return 1;

      // 2. 나머지 주문들은 시간 역순으로 정렬 (최신 주문이 뒤로)
      if (a.status != 'served' && b.status != 'served') {
        return a.createdAt.compareTo(b.createdAt); // 이전 주문이 앞으로, 새 주문이 뒤로
      }

      // 3. served 주문들끼리는 시간순 정렬
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  // 주석: 새로운 함수 - 새 주문 탭 활성화
  void _activateNewOrderTab(List<Order> currentOrders) {
    if (_previousOrders == null) {
      _previousOrders = currentOrders;
      return;
    }

    // 새로운 pending 주문 찾기
    final newPendingOrders = currentOrders
        .where((order) =>
            order.status == 'pending' &&
            !_previousOrders!.any((prev) => prev.id == order.id))
        .toList();

    if (newPendingOrders.isNotEmpty) {
      // 새 주문의 인덱스 찾기
      final newOrderIndex = currentOrders.indexOf(newPendingOrders.last);
      setState(() {
        _currentIndex = newOrderIndex;
      });
    }

    _previousOrders = currentOrders;
  }

  // 주석: 테이블 크기 계산 함수 추가
// 주석: 테이블 크기 계산 함수 수정
  Size _calculateTableSize(List<Order> tableOrders) {
    double baseWidth = widget.table.width;

    // 주석: _currentIndex 유효성 검사 추가
    if (_currentIndex >= tableOrders.length) {
      _currentIndex = tableOrders.isEmpty ? 0 : tableOrders.length - 1;
    }

    // 주석: null safety와 범위 체크를 통합
    final currentOrder = tableOrders.isEmpty
        ? null
        : (_currentIndex >= 0 && _currentIndex < tableOrders.length
            ? tableOrders[_currentIndex]
            : null);

    // 주석: safe한 아이템 카운트 계산
    final itemCount = currentOrder?.items?.length ?? 0;

    // 주석: 각 항목별 필요한 높이 계산
    double headerHeight = 46.0; // 테이블 헤더
    double tabsHeight = tableOrders.isEmpty ? 0.0 : 30.0; // 탭
    double itemHeight = itemCount * 33.0; // 각 아이템 (패딩 포함)
    double buttonHeight = tableOrders.isEmpty ? 0.0 : 50.0; // 버튼 영역
    double totalPadding = 32.0; // 전체 패딩

    // 주석: 전체 필요한 높이 계산
    double requiredHeight =
        headerHeight + tabsHeight + itemHeight + buttonHeight + totalPadding;
    double finalHeight = math.max(widget.table.height, requiredHeight);

    // 주석: 최소 높이 보장
    finalHeight = math.max(finalHeight, 200.0);

    return Size(baseWidth, finalHeight);
  }

  @override
  Widget build(BuildContext context) {
    final List<Order> tableOrders = _sortOrders(_mergeServedOrders(widget
        .orderQueue
        .where((order) => order.tableId == widget.table.tableId)
        .toList()));

    // 주석: 새 주문 탭 활성화 로직 추가
    _activateNewOrderTab(tableOrders);

    final totalAmount =
        tableOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

// 주석: 테이블 크기 계산
    final Size tableSize = _calculateTableSize(tableOrders);

    // 현재 인덱스가 유효한지 확인하고 조정
    if (_currentIndex >= tableOrders.length) {
      _currentIndex = tableOrders.isEmpty ? 0 : tableOrders.length - 1;
    }

    return SingleChildScrollView(
      child: Container(
        width: tableSize.width,
        constraints: BoxConstraints(
          minWidth: widget.table.width,
          minHeight: widget.table.height,
          maxWidth: widget.table.width * 3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTableHeader(tableOrders, totalAmount),
                if (tableOrders.isNotEmpty) _buildOrderTabs(tableOrders),
                if (tableOrders.isNotEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildOrderDetails(tableOrders[_currentIndex])],
                  )
                else
                  Center(
                    child: Text('주문 없음', style: TextStyle(color: Colors.grey)),
                  ),
                // 주석: 결제 버튼의 공간을 확보하기 위한 여백
                SizedBox(height: 50),
              ],
            ),
            // 주석: 결제 버튼을 Positioned로 하단에 고정
            if (tableOrders.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  // 주석: Center 위젯으로 감싸서 가운데 정렬
                  child: Center(
                    child: SizedBox(
                      // 주석: 버튼의 가로 크기를 제한
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () =>
                            widget.handlePayment(widget.table.tableId),
                        child: Text('결제', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size(50, 30),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<Order> tableOrders, double totalAmount) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[700],
            ),
            child: Center(
              child: Text(
                '${widget.table.tableId}',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (tableOrders.isNotEmpty)
            Text(
              '총액: ${widget.formatNumber(totalAmount)}원',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderTabs(List<Order> orders) {
    return Container(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          bool isServed = order.status == 'served';
          Color backgroundColor = isServed
              ? Colors.green
              : (order.status == 'pending' ? Colors.red : Colors.blue);
          int orderNumber =
              widget.orderQueueController.getOrderNumber(order.id);

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
              widget.handleTabChange(widget.table.tableId, index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              margin: EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _currentIndex == index ? backgroundColor : Colors.grey,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isServed)
                    Icon(Icons.check_circle, size: 20, color: Colors.white)
                  else if (orderNumber > 0)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          '$orderNumber',
                          style: TextStyle(
                            color: backgroundColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(Icons.receipt, size: 20, color: Colors.white),
                  SizedBox(width: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    bool isCallOrder = order.items.every((item) => item.price == 0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Column(
                    // 주석: Column으로 변경하여 옵션을 아래에 표시
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                                children: [
                                  TextSpan(text: item.name),
                                  TextSpan(text: ' '),
                                  TextSpan(
                                    text: '${item.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isCallOrder)
                            Text(
                              '${widget.formatNumber(item.quantity * item.price)}원',
                              style: TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      // 주석: 선택된 옵션이 있는 경우 표시
                      if (item.selectedOptions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.selectedOptions.map((option) {
                              // return Text(
                              //   '${option.name}: ${option.choice}--${option.price}',
                              //   style: TextStyle(
                              //     fontSize: 10,
                              //     color: Colors.grey[600],
                              //   ),
                              return Text(
                                ' ${option.choice}--${NumberFormat('#,###').format(option.price)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis, // 주석: 긴 텍스트 처리
                                maxLines: 1, // 주석: 한 줄로 제한
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (index < order.items.length - 1) Divider(height: 1),
              ],
            );
          }).toList(),
          if (order.status != 'served')
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isCallOrder) {
                        _handleCallComplete(order);
                      } else {
                        widget.handleOrderStatusChange(
                            widget.table.tableId, order);
                      }
                    },
                    child: Text(
                      isCallOrder ? '호출' : _getStatusText(order.status),
                      style: TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCallOrder
                          ? Colors.red
                          : _getStatusColor(order.status),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(60, 30),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleCallComplete(Order order) {
    final updatedOrder = Order(
      id: order.id,
      restaurantId: order.restaurantId,
      businessDayId: order.businessDayId,
      tableId: order.tableId,
      items: order.items,
      status: 'served',
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      user: order.user,
      isComplimentaryOrder: order.isComplimentaryOrder,
    );

    widget.handleCallComplete(widget.table.tableId, updatedOrder);

    setState(() {
      // 주문 목록을 업데이트하고 UI를 갱신합니다.
      final updatedOrders = _mergeServedOrders(widget.orderQueue
          .where((o) => o.tableId == widget.table.tableId)
          .map((o) => o.id == order.id ? updatedOrder : o)
          .toList());

      // 'served' 상태의 주문이 있다면 그 인덱스로, 없다면 마지막 인덱스로 설정
      _currentIndex = updatedOrders.indexWhere((o) => o.status == 'served');
      if (_currentIndex == -1) {
        _currentIndex = updatedOrders.length - 1;
      }
    });
  }

  List<Order> _mergeServedOrders(List<Order> orders) {
    List<Order> mergedOrders = [];
    Order? servedOrder;

    for (var order in orders) {
      if (order.status == 'served') {
        if (servedOrder == null) {
          servedOrder = order;
        } else {
          // 수정: 새로운 아이템 리스트를 생성하여 중복 아이템을 병합
          List<OrderItem> updatedItems = List.from(servedOrder.items);
          int totalAmount = servedOrder.totalAmount; // 수정: int 타입으로 변경

          // 주석: 각 아이템을 순회하면서 중복 여부를 확인하고 병합
          for (var item in order.items) {
            int existingIndex = updatedItems.indexWhere((existingItem) =>
                existingItem.id == item.id &&
                _areOptionsEqual(
                    existingItem.selectedOptions, item.selectedOptions));

            if (existingIndex != -1) {
              // 주석: 중복 아이템이 있고 옵션이 같은 경우, 수량과 금액을 합침
              var existingItem = updatedItems[existingIndex];
              updatedItems[existingIndex] = OrderItem(
                id: existingItem.id,
                name: existingItem.name,
                price: existingItem.price,
                quantity: existingItem.quantity + item.quantity,
                selectedOptions: existingItem.selectedOptions,
                isComplimentary: existingItem.isComplimentary,
              );
            } else {
              // 주석: 중복되지 않는 아이템은 그대로 추가
              updatedItems.add(item);
            }
            totalAmount += item.price * item.quantity;
          }

          // 주석: 업데이트된 정보로 새로운 Order 객체 생성
          servedOrder = Order(
            id: servedOrder.id,
            restaurantId: servedOrder.restaurantId,
            businessDayId: servedOrder.businessDayId,
            tableId: servedOrder.tableId,
            items: updatedItems,
            status: 'served',
            totalAmount: totalAmount,
            createdAt: servedOrder.createdAt,
            updatedAt: DateTime.now(),
            user: servedOrder.user,
            isComplimentaryOrder: servedOrder.isComplimentaryOrder,
          );
        }
      } else {
        mergedOrders.add(order);
      }
    }

    if (servedOrder != null) {
      mergedOrders.add(servedOrder);
    }

    return mergedOrders;
  }

  // 주석: 옵션이 동일한지 확인하는 헬퍼 메서드 (타입 수정)
  bool _areOptionsEqual(
      List<SelectedOption>? options1, List<SelectedOption>? options2) {
    if (options1 == null && options2 == null) return true;
    if (options1 == null || options2 == null) return false;
    if (options1.length != options2.length) return false;

    for (int i = 0; i < options1.length; i++) {
      if (options1[i].name != options2[i].name ||
          options1[i].choice != options2[i].choice) {
        return false;
      }
    }
    return true;
  }

  Widget _buildPaymentButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => widget.handlePayment(widget.table.tableId),
        child: Text('결제', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size(50, 30),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '주문 접수';
      case 'preparing':
        return '준비중';
      case 'served':
        return '서빙완료';
      default:
        return '완료';
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
      default:
        return Colors.green;
    }
  }
}
