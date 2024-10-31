// file: lib/features/restaurant_menu/widgets/item_detail_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/menu.dart';
import '../controllers/restaurant_menu_controller.dart';
import '../controllers/order_controller.dart'; // 추가: OrderController import
import '../controllers/quick_order_controller.dart'; // 추가: QuickOrderController import
import 'package:intl/intl.dart';
import 'menu_option_bottom_sheet.dart'; // MenuOptionBottomSheet 위젯을 import
// import 'cart_bottom_sheet.dart'; // CartBottomSheet를 import
import '../../../services/auth_service.dart'; // 추가: AuthService import
import '../../../services/fcm_service.dart';
import '../../../controllers/business_day_controller.dart'; // 추가: BusinessDayController import
import 'package:uuid/uuid.dart'; // 추가: Uuid import
import '../../../models/order.dart' as OrderModel; // 추가: Order 모델 import
import '../../../models/quick_order.dart'
    as QuickOrderModel; // 추가: QuickOrder 모델 import

class ItemDetailBottomSheet extends GetView<RestaurantMenuController> {
  final MenuItem item;
  final NumberFormat currencyFormat = NumberFormat('#,###', 'ko_KR');
  // 추가: 필요한 컨트롤러들 선언
  final OrderController orderController = Get.find<OrderController>();
  final QuickOrderController quickOrderController =
      Get.find<QuickOrderController>();
  final AuthService authService = Get.find<AuthService>();
  final BusinessDayController businessDayController =
      Get.find<BusinessDayController>();
  static const _uuid = Uuid();
  // 수정: 로딩 상태를 관리하기 위한 RxBool 추가
  final RxBool isLoading = false.obs;

  ItemDetailBottomSheet({super.key, required this.item});

//*
// */
  List<OrderModel.SelectedOption> _convertToSelectedOptions(
      Map<String, List<String>> options) {
    final List<OrderModel.SelectedOption> result = [];

    options.forEach((optionName, choices) {
      for (final choice in choices) {
        result.add(
          OrderModel.SelectedOption(
            name: optionName,
            choice: choice,
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
      for (final choice in choices) {
        // 옵션의 가격 계산 로직 추가
        int choicePrice = 0;
        for (final menuItem in controller.cart) {
          final option = menuItem.options.firstWhere(
            (opt) => opt.name == optionName,
            orElse: () => MenuItemOption(name: '', choices: []),
          );
          final menuChoice = option.choices.firstWhere(
            (ch) => ch.name == choice,
            orElse: () => Choice(name: '', price: 0),
          );
          choicePrice = menuChoice.price;
          break;
        }

        result.add(
          QuickOrderModel.SelectedOption(
            name: optionName,
            choice: choice,
            price: choicePrice, // 주석: 실제 선택된 옵션의 가격 추가
          ),
        );
      }
    });

    return result;
  }

  // 추가: Order 생성 메서드
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
                selectedOptions: _convertToSelectedOptions(
                    item.selectedOptions), // 주석: 타입 캐스팅 추가
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

  // 추가: QuickOrder 생성 메서드
  QuickOrderModel.QuickOrder _createQuickOrder() {
    final userId = authService.currentUser.value?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final businessDayId = businessDayController.currentBusinessDayId.value;
    if (businessDayId == null) {
      throw Exception('No active business day');
    }

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
                    item.selectedOptions), // 주석: 타입 캐스팅 추가
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

  // // 추가: SelectedOption 변환 메서드들
  // List<OrderModel.SelectedOption> _convertToSelectedOptions(
  //     Map<String, String> options) {
  //   return options.entries
  //       .map((entry) => OrderModel.SelectedOption(
  //             name: entry.key,
  //             choice: entry.value,
  //           ))
  //       .toList();
  // }

  // List<QuickOrderModel.SelectedOption> _convertToSelectedOptionsForQuickOrder(
  //     Map<String, String> options) {
  //   return options.entries
  //       .map((entry) => QuickOrderModel.SelectedOption(
  //             name: entry.key,
  //             choice: entry.value,
  //             price: 0,
  //           ))
  //       .toList();
  // }

  Future<void> _handleDirectOrder() async {
    try {
      isLoading.value = true;

// 먼저 business day 상태 체크
      await businessDayController
          .checkBusinessDayStatus(controller.restaurantId);

      if (!businessDayController.isBusinessDayActive.value) {
        Get.snackbar(
          '영업 종료',
          '현재 영업 중이 아닙니다. 주문이 불가능합니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 비즈니스 데이가 활성화되어 있는지 다시 한번 확인
      if (businessDayController.currentBusinessDayId.value == null) {
        throw Exception('영업일이 시작되지 않았습니다. 잠시 후 다시 시도해주세요.');
      }

      controller.clearCart();
      controller.addToCart(item);

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
      Get.snackbar('오류 item detail sheet', '주문 처리 중 오류가 발생했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: item.images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                item.images[0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildRestaurantIcon();
                                },
                              ),
                            )
                          : _buildRestaurantIcon(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.description ?? 'No description available',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${currencyFormat.format(item.price)}원',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    Text(
                      item.detailedDescription ?? "",
                      style: const TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          // 수정: 로딩 중일 때 버튼 비활성화
                          onPressed: isLoading.value
                              ? null
                              : () async {
                                  if (item.options.isNotEmpty) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (BuildContext context) {
                                        return MenuOptionBottomSheet(
                                          item: item,
                                          mode: OptionMode.orderNow,
                                        );
                                      },
                                    );
                                  } else {
                                    await _handleDirectOrder(); // 수정: 새로운 주문 처리 메소드 호출
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          // 수정: 로딩 상태에 따른 버튼 텍스트 변경
                          child: isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  '바로 주문하기',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        )),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 주석: async 추가
                        if (item.options.isNotEmpty) {
                          // 주석: await를 추가하고 옵션 선택 후 현재 시트도 닫음
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return MenuOptionBottomSheet(
                                item: item,
                                mode: OptionMode.addToCart,
                              );
                            },
                          );
                          // 주석: 옵션 선택 완료 후 ItemDetailBottomSheet도 닫기
                          if (context.mounted) Navigator.pop(context);
                        } else {
                          controller.addToCart(item);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        '장바구니에 추가',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantIcon() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }
}
