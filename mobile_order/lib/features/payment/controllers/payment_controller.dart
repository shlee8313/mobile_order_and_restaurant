// file: lib/features/payment/controllers/payment_controller.dart

import 'package:get/get.dart';
import '../../../models/order.dart';
import '../../../models/quick_order.dart';
import '../../../models/menu.dart';
import '../../restaurant_menu/controllers/restaurant_menu_controller.dart';
import '../../restaurant_menu/controllers/order_controller.dart';
import '../../restaurant_menu/controllers/quick_order_controller.dart';
import '../../../controllers/business_day_controller.dart';
import '../../../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class PaymentController extends GetxController {
  // final String restaurantId;
  // final String? tableId;

  // PaymentController({required this.restaurantId, this.tableId});
  final RestaurantMenuController _menuController =
      Get.find<RestaurantMenuController>();

  final OrderController _orderController = Get.find<OrderController>();
  final QuickOrderController _quickOrderController =
      Get.find<QuickOrderController>();
  final BusinessDayController _businessDayController =
      Get.find<BusinessDayController>();
  final AuthService _authService = Get.find<AuthService>();
  static const _uuid = Uuid();

  late Rx<Order?> _order;
  Order? get order => _order.value;

  late Rx<QuickOrder?> _quickOrder;
  QuickOrder? get quickOrder => _quickOrder.value;
  RxInt _totalAmount = 0.obs;
  int get totalAmount => _totalAmount.value;

  RxBool isLoading = false.obs;

  /***
   * 
   */
  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments;
    _order = Rx<Order?>(args['order'] as Order?);
    _quickOrder = Rx<QuickOrder?>(args['quickOrder'] as QuickOrder?);
    _updateTotalAmount();
  }

  Future<bool> processPayment() async {
    try {
      isLoading.value = true;

      // 영업일 상태 확인
      await _businessDayController
          .checkBusinessDayStatus(_menuController.restaurantId);
      if (!_businessDayController.isBusinessDayActive.value) {
        Get.snackbar('영업 종료', '현재 영업 중이 아닙니다. 주문이 불가능합니다.');
        return false;
      }

      // 결제 처리 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 주문 처리
      if (order != null) {
        await _orderController.placeOrder(order!);
      } else if (quickOrder != null) {
        await _quickOrderController.placeQuickOrder(quickOrder!);
      }

      _menuController.clearCart();
      return true;
    } catch (e) {
      print('Payment error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 총 결제 금액을 계산하는 메서드
  int getTotalAmount() {
    if (order != null) {
      return order!.totalAmount;
    } else if (quickOrder != null) {
      return quickOrder!.totalAmount;
    }
    return 0;
  }

  void _updateTotalAmount() {
    if (_order.value != null) {
      _totalAmount.value = _order.value!.items
          .fold(0, (sum, item) => sum + (item.price * item.quantity));
    } else if (_quickOrder.value != null) {
      _totalAmount.value = _quickOrder.value!.items
          .fold(0, (sum, item) => sum + (item.price * item.quantity));
    }
  }

  void removeItem(int index) {
    if (_order.value != null) {
      final removedItem = _order.value!.items[index];
      final updatedItems = List<OrderItem>.from(_order.value!.items);
      updatedItems.removeAt(index);
      _order.value = _order.value!.copyWith(items: updatedItems);

      // 주석: 옵션과 함께 장바구니에서 메뉴 찾기
      final cartItem = _menuController.cart.firstWhere((menuItem) {
        // 주석: 장바구니 아이템의 id가 같고
        if (menuItem.id != removedItem.id) return false;

        // 주석: 선택된 옵션이 모두 같은지 비교
        final menuItemOptions = menuItem.selectedOptions;
        if (menuItemOptions.length != removedItem.selectedOptions.length)
          return false;

        // 주석: 각 옵션의 이름과 선택값이 모두 일치하는지 확인
        return removedItem.selectedOptions.every((orderOption) {
          final selectedChoices = menuItemOptions[orderOption.name];
          return selectedChoices != null &&
              selectedChoices.contains(orderOption.choice);
        });
      }, orElse: () => MenuItem(id: '', name: '', price: 0));

      // 주석: 찾은 아이템이 유효하면 장바구니에서 삭제
      if (cartItem.id.isNotEmpty) {
        _menuController.removeFromCart(cartItem);
      }
    } else if (_quickOrder.value != null) {
      final removedItem = _quickOrder.value!.items[index];
      final updatedItems = List<QuickOrderItem>.from(_quickOrder.value!.items);
      updatedItems.removeAt(index);
      _quickOrder.value = _quickOrder.value!.copyWith(items: updatedItems);

      // 주석: QuickOrder도 동일한 로직 적용
      final cartItem = _menuController.cart.firstWhere((menuItem) {
        if (menuItem.id != removedItem.id) return false;

        final menuItemOptions = menuItem.selectedOptions;
        if (menuItemOptions.length != removedItem.selectedOptions.length)
          return false;

        return removedItem.selectedOptions.every((orderOption) {
          final selectedChoices = menuItemOptions[orderOption.name];
          return selectedChoices != null &&
              selectedChoices.contains(orderOption.choice);
        });
      }, orElse: () => MenuItem(id: '', name: '', price: 0));

      if (cartItem.id.isNotEmpty) {
        _menuController.removeFromCart(cartItem);
      }
    }
    _updateTotalAmount();
    update();
  }
}
