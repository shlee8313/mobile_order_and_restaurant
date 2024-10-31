//file: \lib\features\restaurant_menu\controllers\restaurant_menu_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/restaurant.dart';
import '../../../models/menu.dart';
import '../../../services/restaurant_service.dart';
import '../../../models/order.dart';
import './order_controller.dart';
import '../../../services/auth_service.dart';
import '../widgets/menu_option_bottom_sheet.dart';
import '../../../controllers/business_day_controller.dart';
import 'package:uuid/uuid.dart';
import '../widgets/cart_bottom_sheet.dart';

/**
 * 레스토랑 메뉴 컨트롤러
 */
/// 레스토랑 메뉴 컨트롤러
class RestaurantMenuController extends GetxController {
  final RestaurantService _restaurantService = Get.find<RestaurantService>();

  final Rx<Restaurant?> restaurant = Rx<Restaurant?>(null);
  final Rx<Menu?> menu = Rx<Menu?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = RxString('');
  final RxList<MenuItem> cart = <MenuItem>[].obs;
  String get restaurantTitle =>
      restaurant.value?.businessName ?? 'Restaurant Menu';
  int get cartItemCount => cart.length;
  final String restaurantId;
  final String? tableId;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxMap<String, int> _itemQuantities = <String, int>{}.obs;
  bool get hasTables => restaurant.value?.hasTables ?? false; // 새로 추가된 getter
  RestaurantMenuController({required this.restaurantId, this.tableId});
  // final OrderController _orderController = Get.find<OrderController>();
  late OrderController _orderController;
  final AuthService authService = Get.find<AuthService>(); // 추가: AuthService 주입
  final BusinessDayController _businessDayController =
      Get.find<BusinessDayController>();
  static const _uuid = Uuid();

  int getItemQuantityObs(MenuItem item) => _itemQuantities[item.id] ?? 0;

  @override
  void onInit() {
    super.onInit();
    _orderController = Get.find<OrderController>();
    fetchRestaurantAndMenu();
  }

  Future<void> fetchRestaurantAndMenu() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      restaurant.value =
          await _restaurantService.getRestaurantInfo(restaurantId);
      if (restaurant.value != null) {
        menu.value = await _restaurantService.getRestaurantMenu(restaurantId);
      } else {
        errorMessage.value = 'Failed to load restaurant information';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data: ${e.toString()}';
    } finally {
      isLoading.value = false;
      update(); // GetBuilder를 사용하고 있으므로 update() 호출
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    update(); // GetX의 update() 메서드를 호출하여 UI 갱신
  }

  /// 카트에 아이템 추가
  void addToCart(MenuItem item,
      [Map<String, List<String>>?
          selectedOptions, // 주석: List<String>으로 변경하여 다중 선택 지원
      OptionMode mode = OptionMode.addToCart]) {
    if (item.price == 0) {
      _placeZeroPriceOrder(item);
      return;
    }

    if (item.options.isNotEmpty && selectedOptions == null) {
      Get.bottomSheet(
        MenuOptionBottomSheet(
          item: item,
          mode: mode,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    } else {
      _addItemWithOptions(item, selectedOptions ?? {}); // 주석: 빈 Map으로 초기화

      if (mode == OptionMode.orderNow) {
        Future.delayed(const Duration(milliseconds: 100), () async {
          final cartBottomSheet = CartBottomSheet();
          await cartBottomSheet.processOrder();
        });
      }
    }
  }

// void addToCartFromMenuPage(MenuItem item,
//       [Map<String, String>? selectedOptions,
//       OptionMode mode = OptionMode.addToCart]) {
//     // Copy the logic from addToCart
//     if (item.price == 0) {
//       _placeZeroPriceOrder(item);
//       return;
//     }

//     if (item.options.isNotEmpty && selectedOptions == null) {
//       Get.bottomSheet(
//         MenuOptionBottomSheet(
//           item: item,
//           mode: mode,
//         ),
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//       );
//     } else {
//       _addItemWithOptions(item, selectedOptions ?? {});

//     }
//   }

  String getItemKey(MenuItem item) {
    // 옵션을 정렬하여 일관된 문자열 생성
    final sortedOptions = item.selectedOptions.entries.map((entry) {
      final sortedChoices = List<String>.from(entry.value)..sort();
      return '${entry.key}:${sortedChoices.join(",")}';
    }).toList()
      ..sort();

    return '${item.id}_${sortedOptions.join("_")}';
  }

  void _addItemWithOptions(
      MenuItem item, Map<String, List<String>> selectedOptions) {
    final itemKey = getItemKey(item.copyWith(selectedOptions: selectedOptions));

    // existingItemIndex 찾을 때 itemKey로 비교
    final existingItemIndex =
        cart.indexWhere((cartItem) => getItemKey(cartItem) == itemKey);

    // 주석: 선택된 옵션의 총 가격 계산 로직
    int totalOptionPrice = 0;
    selectedOptions.forEach((optionName, selectedChoices) {
      final option = item.options.firstWhere((opt) => opt.name == optionName);
      for (var choiceName in selectedChoices) {
        final choice = option.choices.firstWhere((ch) => ch.name == choiceName);
        totalOptionPrice += choice.price;
      }
    });

    if (existingItemIndex != -1) {
      _itemQuantities[itemKey] = (_itemQuantities[itemKey] ?? 0) + 1;
    } else {
      cart.add(item.copyWith(
        selectedOptions: selectedOptions,
        price: item.price + totalOptionPrice,
      ));
      _itemQuantities[itemKey] = 1;
    }
    update();
  }

  // bool _compareOptions(Map<String, List<String>>? options1,
  //     Map<String, List<String>>? options2) {
  //   if (options1 == null || options2 == null) return options1 == options2;
  //   if (options1.length != options2.length) return false;

  //   return options1.entries.every((e) {
  //     final list2 = options2[e.key];
  //     if (list2 == null || e.value.length != list2.length) return false;
  //     return e.value.every((v) => list2.contains(v));
  //   });
  // }

  Future<void> _placeZeroPriceOrder(MenuItem item) async {
    try {
      // 1. 영업일 상태 확인
      await _businessDayController.checkBusinessDayStatus(restaurantId);

      // 2. 영업일이 활성화되지 않았으면 에러 메시지 표시
      if (!_businessDayController.isBusinessDayActive.value) {
        Get.snackbar('영업 종료', '현재 영업 중이 아닙니다. 주문이 불가능합니다.');
        return;
      }

      if (tableId == null || tableId!.isEmpty) {
        Get.snackbar('오류', '테이블 번호가 없습니다.');
        return;
      }

      final int? parsedTableId = int.tryParse(tableId!);
      if (parsedTableId == null) {
        Get.snackbar('오류', '올바르지 않은 테이블 번호입니다.');
        return;
      }

      final userId = authService.currentUser.value?.uid;
      if (userId == null) {
        Get.snackbar('오류', '사용자 인증에 실패했습니다.');
        return;
      }

      final String? businessDayId =
          _businessDayController.currentBusinessDayId.value;
      if (businessDayId == null) {
        Get.snackbar('오류', '영업일 정보를 가져오는데 실패했습니다.');
        return;
      }

      final order = Order(
        id: _uuid.v4(),
        restaurantId: restaurantId,
        businessDayId: businessDayId,
        tableId: parsedTableId,
        items: [
          OrderItem(
            id: item.id,
            name: item.name,
            price: 0,
            quantity: 1,
            selectedOptions: [], // 무료 메뉴는 옵션이 없다고 가정
          )
        ],
        status: 'pending',
        totalAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isComplimentaryOrder: true,
        user: userId,
      );

      await _orderController.placeOrder(order);
      // Get.snackbar('주문 완료', '${item.name}이(가) 주문되었습니다.');
    } catch (e) {
      Get.snackbar('오류', '주문 처리 중 오류가 발생했습니다: $e');
    }
  }

  // }

  // void _placeZeroPriceOrder(MenuItem item) {
  //   if (tableId == null || tableId!.isEmpty) {
  //     Get.snackbar('오류', '테이블 번호가 없습니다.');
  //     return;
  //   }

  //   final int? parsedTableId = int.tryParse(tableId!);
  //   if (parsedTableId == null) {
  //     Get.snackbar('오류', '올바르지 않은 테이블 번호입니다.');
  //     return;
  //   }

  //   final order = Order(
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     restaurantId: restaurantId,
  //     tableId: parsedTableId,
  //     items: [
  //       OrderItem(
  //         id: item.id,
  //         name: item.name,
  //         price: 0,
  //         quantity: 1,
  //       )
  //     ],
  //     status: 'pending',
  //     totalAmount: 0,
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //     isComplimentaryOrder: true,
  //     user: '', // 이 부분은 실제 사용자 ID로 채워져야 합니다.
  //   );

  //   _orderController.placeOrder(order);
  // }

  /// 카트에서 아이템 제거
  void removeFromCart(MenuItem item) {
    final itemKey = getItemKey(item);
    cart.removeWhere((cartItem) => getItemKey(cartItem) == itemKey);
    _itemQuantities.remove(itemKey);
    update();
  }

  void clearCart() {
    cart.clear();
    update();
  }

  void removeItemById(String itemId) {
    cart.removeWhere((cartItem) => cartItem.id == itemId);
    _itemQuantities.remove(itemId);
    update();
  }

  /// 카트 아이템 수량 증가
  /// 카트 아이템 수량 증가
  void increaseItemQuantity(MenuItem item) {
    final itemKey = getItemKey(item);
    _itemQuantities[itemKey] = (_itemQuantities[itemKey] ?? 0) + 1;
    var index = cart.indexWhere((cartItem) => getItemKey(cartItem) == itemKey);
    if (index != -1) {
      cart[index] = cart[index];
    }
    cart.refresh();
  }

  void decreaseItemQuantity(MenuItem item) {
    final itemKey = getItemKey(item);
    if (_itemQuantities[itemKey] != null && _itemQuantities[itemKey]! > 1) {
      _itemQuantities[itemKey] = _itemQuantities[itemKey]! - 1;
      var index =
          cart.indexWhere((cartItem) => getItemKey(cartItem) == itemKey);
      if (index != -1) {
        cart[index] = cart[index];
      }
      cart.refresh();
    } else {
      removeFromCart(item);
    }
  }

  int getItemQuantity(MenuItem item) {
    final itemKey = getItemKey(item);
    return _itemQuantities[itemKey] ?? 0;
  }

  /// 카트 아이템 수량 업데이트
  void updateCartItem(String id, int quantity) {
    final itemIndex = cart.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      if (quantity > 0) {
        _itemQuantities[id] = quantity;
      } else {
        removeFromCart(cart[itemIndex]);
      }
    }
    update();
  }

  /// 카트 아이템 수량 조회
  // int getItemQuantity(MenuItem item) {
  //   return _itemQuantities[item.id] ?? 0;
  // }

  /// 카트 총 금액 계산
  int getTotalPrice() {
    return cart.fold(0, (sum, item) {
      final quantity = getItemQuantity(item);

      // 주석: item.price에 이미 옵션 가격이 포함되어 있으므로
      // 단순히 price와 quantity를 곱하면 됩니다.
      final totalItemPrice = item.price * quantity;

      return sum + totalItemPrice;
    });
  }

  // 상태가 변경될 때마다 이 메서드를 호출
  // void updateState() {
  //   update();
  // }
}
