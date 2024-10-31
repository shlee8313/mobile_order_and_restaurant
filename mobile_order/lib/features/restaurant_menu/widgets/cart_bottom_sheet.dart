//file: \lib\features\restaurant_menu\widgets\cart_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/restaurant_menu_controller.dart';
import '../../../services/fcm_service.dart';
import '../controllers/order_controller.dart';
import '../controllers/quick_order_controller.dart';
import '../../../controllers/business_day_controller.dart';
import '../../../models/menu.dart';
import '../../../models/order.dart' as OrderModel;
import '../../../models/quick_order.dart' as QuickOrderModel;
import '../../../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class CartBottomSheet extends GetView<RestaurantMenuController> {
  final NumberFormat currencyFormat = NumberFormat('#,###', 'ko_KR');
  final OrderController orderController = Get.find<OrderController>();
  final QuickOrderController quickOrderController =
      Get.find<QuickOrderController>();
  final AuthService authService = Get.find<AuthService>();
  final BusinessDayController businessDayController =
      Get.find<BusinessDayController>();
  static const _uuid = Uuid();

  CartBottomSheet({super.key});

  Future<void> processOrder() async {
    await _processOrder();
  }

  Future<void> _processOrder() async {
    try {
      await businessDayController
          .checkBusinessDayStatus(controller.restaurantId);

      if (!businessDayController.isBusinessDayActive.value) {
        Get.snackbar('영업 종료', '현재 영업 중이 아닙니다. 주문이 불가능합니다.');
        return;
      }

      Map<String, dynamic> arguments;
      if (controller.hasTables) {
        final order = _createOrder();
        arguments = {'order': order};
      } else {
        final quickOrder = _createQuickOrder();
        arguments = {'quickOrder': quickOrder};
      }

      await Get.toNamed('/payment', arguments: arguments);
    } catch (e) {
      Get.snackbar('오류 cart bottom sheet', '주문 처리 중 오류가 발생했습니다: $e');
    }
  }

  List<OrderModel.SelectedOption> _convertToSelectedOptions(
      Map<String, List<String>> options) {
    final List<OrderModel.SelectedOption> result = [];

    options.forEach((optionName, choices) {
      final menuItem = controller.cart.firstWhere(
        (item) => item.options.any((opt) => opt.name == optionName),
        orElse: () => MenuItem(id: '', name: '', price: 0),
      );

      final option = menuItem.options.firstWhere(
        (opt) => opt.name == optionName,
        orElse: () => MenuItemOption(name: '', choices: []),
      );

      for (final choiceName in choices) {
        final choice = option.choices.firstWhere(
          (ch) => ch.name == choiceName,
          orElse: () => Choice(name: '', price: 0),
        );

        result.add(
          OrderModel.SelectedOption(
            name: optionName,
            choice: choiceName,
            price: choice.price,
          ),
        );
      }
    });

    return result;
  }

  List<QuickOrderModel.SelectedOption> _convertToSelectedOptionsForQuickOrder(
      Map<String, List<String>> options) {
    final List<QuickOrderModel.SelectedOption> result = [];

    options.forEach((optionName, choices) {
      final menuItem = controller.cart.firstWhere(
        (item) => item.options.any((opt) => opt.name == optionName),
        orElse: () => MenuItem(id: '', name: '', price: 0),
      );

      final option = menuItem.options.firstWhere(
        (opt) => opt.name == optionName,
        orElse: () => MenuItemOption(name: '', choices: []),
      );

      for (final choiceName in choices) {
        final choice = option.choices.firstWhere(
          (ch) => ch.name == choiceName,
          orElse: () => Choice(name: '', price: 0),
        );

        result.add(
          QuickOrderModel.SelectedOption(
            name: optionName,
            choice: choiceName,
            price: choice.price,
          ),
        );
      }
    });

    return result;
  }

  OrderModel.Order _createOrder() {
    final userId = authService.currentUser.value?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final businessDayId = businessDayController.currentBusinessDayId.value;
    if (businessDayId == null) {
      throw Exception('No active business day');
    }

    return OrderModel.Order(
      id: _uuid.v4(),
      restaurantId: controller.restaurantId,
      businessDayId: businessDayId,
      tableId: int.parse(controller.tableId!),
      items: controller.cart
          .map((item) => OrderModel.OrderItem(
                id: item.id,
                name: item.name,
                price: item.price,
                quantity: controller.getItemQuantity(item),
                selectedOptions:
                    _convertToSelectedOptions(item.selectedOptions),
              ))
          .toList(),
      status: 'pending',
      totalAmount: controller.getTotalPrice(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isComplimentaryOrder: false,
      user: userId,
    );
  }

  QuickOrderModel.QuickOrder _createQuickOrder() {
    final userId = authService.currentUser.value?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final businessDayId = businessDayController.currentBusinessDayId.value;
    if (businessDayId == null) {
      throw Exception('No active business day');
    }

    // FCM 토큰 가져오기
    final fcmService = Get.find<FCMService>();
    final fcmToken = fcmService.fcmToken;
    print('Creating QuickOrder with FCM token: $fcmToken'); // 디버깅용 로그

    return QuickOrderModel.QuickOrder(
      id: _uuid.v4(),
      restaurantId: controller.restaurantId,
      businessDayId: businessDayId,
      items: controller.cart
          .map((item) => QuickOrderModel.QuickOrderItem(
                id: item.id,
                name: item.name,
                price: item.price,
                quantity: controller.getItemQuantity(item),
                selectedOptions: _convertToSelectedOptionsForQuickOrder(
                    item.selectedOptions),
              ))
          .toList(),
      status: 'pending',
      totalAmount: controller.getTotalPrice(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: userId,
      fcmToken: fcmToken, // FCM 토큰 추가
    );
  }

  // 주석: 선택된 옵션들을 표시하기 위한 새로운 헬퍼 메서드
  Widget _buildSelectedOptionsChips(
      Map<String, List<String>> selectedOptions, MenuItem item) {
    return Container(
      margin: EdgeInsets.zero,
      child: Wrap(
        spacing: 2, // 가로 간격 최소화
        runSpacing: 0, // 세로 줄간격 제거
        children: selectedOptions.entries.map((entry) {
          final option = item.options.firstWhere(
            (opt) => opt.name == entry.key,
            orElse: () => MenuItemOption(name: '', choices: []),
          );

          return Container(
            margin: EdgeInsets.only(top: 2), // 옵션 그룹간 간격
            child: Wrap(
              spacing: 2,
              runSpacing: -6,
              children: entry.value.map((choice) {
                final choiceObj = option.choices.firstWhere(
                  (ch) => ch.name == choice,
                  orElse: () => Choice(name: '', price: 0),
                );

                return Transform.translate(
                  offset: const Offset(0, -2), // 위로 살짝 이동
                  child: Container(
                    constraints: BoxConstraints(minHeight: 16), // 최소 높이 지정
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      labelPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: -4),
                      padding: EdgeInsets.zero,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$choice',
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1, // 줄높이 최소화
                            ),
                          ),
                          if (choiceObj.price > 0) const SizedBox(width: 2),
                          Text(
                            ' (+${NumberFormat('#,###').format(choiceObj.price)}원)',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1, // 줄높이 최소화
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(style: BorderStyle.none),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.8,
      maxChildSize: 0.8,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '장바구니',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.cart.isEmpty) {
                    return const Center(child: Text('장바구니가 비어 있습니다.'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.cart.length,
                    itemBuilder: (context, index) {
                      final item = controller.cart[index];

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item.selectedOptions.isNotEmpty)
                                      _buildSelectedOptionsChips(
                                        item.selectedOptions,
                                        item,
                                      ),
                                  ],
                                ),
                              ),
                              // 주석: 수량 조절 및 가격 표시 부분을 Obx로 감싸서 실시간 업데이트
                              Obx(() {
                                final quantity =
                                    controller.getItemQuantity(item);
                                final totalItemPrice = item.price * quantity;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .end, // 주석: 모든 자식 위젯을 오른쪽으로 정렬
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            size: 30,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () => controller
                                              .decreaseItemQuantity(item),
                                        ),
                                        Text(
                                          '$quantity',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            size: 30,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () => controller
                                              .increaseItemQuantity(item),
                                        ),
                                        const SizedBox(width: 16),
                                        // Text(
                                        //   '${currencyFormat.format(totalItemPrice)}원',
                                        //   style: const TextStyle(
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
                                        // ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.grey[600],
                                            size: 30,
                                          ),
                                          onPressed: () =>
                                              controller.removeFromCart(item),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${currencyFormat.format(totalItemPrice)}원',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              // IconButton(
                              //   icon: Icon(
                              //     Icons.delete,
                              //     color: Colors.grey[600],
                              //     size: 30,
                              //   ),
                              //   onPressed: () =>
                              //       controller.removeFromCart(item),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              // 주석: 하단 합계 및 주문 버튼
              Obx(() {
                if (controller.cart.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              '합계:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(controller.getTotalPrice())}원',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(vertical: 5),
                            ),
                            onPressed: _processOrder,
                            child: const Text(
                              '주문하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
