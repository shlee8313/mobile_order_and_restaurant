// lib/features/restaurant_menu/views/restaurant_menu_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/restaurant_menu_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/quick_order_controller.dart';
import '../../../navigation/controllers/navigation_controller.dart';
import '../../../main.dart'; // MainScreen import 추가
import '../widgets/cart_bottom_sheet.dart'; // 새로 추가된 import
import '../widgets/item_detail_bottom_sheet.dart';
import '../widgets/menu_option_bottom_sheet.dart';
import '../widgets/order_history_bottom_sheet.dart';
import '../widgets/zero_price_bottom_sheet.dart';
import 'dart:math' as math;

///
class RestaurantMenuPage extends GetView<RestaurantMenuController> {
  RestaurantMenuPage({super.key});
  // 애니메이션을 위한 키 추가
  // final GlobalKey _cartIconKey = GlobalKey();
  final NavigationController _navigationController =
      Get.find<NavigationController>();
  final OrderController _orderController = Get.find<OrderController>();
  final QuickOrderController _quickOrderController =
      Get.find<QuickOrderController>();
  final NumberFormat currencyFormat = NumberFormat('#,###', 'ko_KR');

  void _showCart() {
    Get.bottomSheet(
      CartBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _goToHomePage() {
    _navigationController.changePage(0);
    Get.offAll(() => MainScreen());
  }

  void _showOrderHistory() async {
    final restaurantId = controller.restaurantId;
    final hasTables = controller.hasTables;
    final restaurantTitle = controller.restaurantTitle; // 레스토랑 이름 가져오기
    List<dynamic> orders = [];
    if (hasTables) {
      orders = await _orderController.getCustomerOrders(restaurantId);
    } else {
      orders = await _quickOrderController.getCustomerQuickOrders(restaurantId);
    }

    Get.bottomSheet(
      OrderHistoryBottomSheet(
        orders: orders,
        hasTables: hasTables,
        restaurantName: restaurantTitle,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      // 레스토랑 이름 전달
    );
  }

  // void _showCardMenu() {
  //   // TODO: Implement card menu functionality
  //   Get.snackbar('카드 메뉴', '카드 메뉴 기능이 곧 구현될 예정입니다.');
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        _goToHomePage();
      },
      child: GetBuilder<RestaurantMenuController>(
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToHomePage,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.restaurantTitle,
                      style: const TextStyle(fontSize: 25),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (controller.tableId != null)
                    Text(
                      'No: ${controller.tableId}',
                      style: const TextStyle(fontSize: 18),
                    ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.credit_card),
                      onPressed: _showOrderHistory,
                      iconSize: 30,
                      tooltip: '주문 내역',
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    // key: _cartIconKey, // 카트 아이콘에 키 추가
                    // alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined),
                        iconSize: 30,
                        onPressed: _showCart,
                        tooltip: '카트',
                      ),
                      Obx(() {
                        final itemCount = controller.cartItemCount;
                        return itemCount > 0
                            ? Positioned(
                                right: 5,
                                top: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    itemCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 20)
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 10),
                _buildCategoryList(),
                const SizedBox(height: 10),
                Expanded(child: _buildMenuItems()),
              ],
            ),
            // floatingActionButton: CartIconButton(
            //   itemCount: controller.cartItemCount,
            //   onPressed: _showCart,
            // ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return GetBuilder<RestaurantMenuController>(builder: (controller) {
      if (controller.isLoading.value || controller.menu.value == null) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.menu.value!.categories.length,
          itemBuilder: (context, index) {
            final category = controller.menu.value!.categories[index];
            return Obx(() => GestureDetector(
                  onTap: () => controller.selectCategory(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: controller.selectedCategoryIndex.value == index
                          ? Colors.blue
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: controller.selectedCategoryIndex.value == index
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ));
          },
        ),
      );
    });
  }

  Widget _buildMenuItems() {
    return GetBuilder<RestaurantMenuController>(builder: (controller) {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.menu.value == null) {
        return const Center(child: Text('Menu not available'));
      }

      final selectedCategory = controller
          .menu.value!.categories[controller.selectedCategoryIndex.value];

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: selectedCategory.items.length,
        itemBuilder: (context, index) {
          final item = selectedCategory.items[index];
          return GestureDetector(
            onTap: () {
              if (item.price == 0) {
                Get.bottomSheet(
                  ZeroPriceBottomSheet(
                    item: item,
                    controller: controller,
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              } else {
                Get.bottomSheet(
                  ItemDetailBottomSheet(item: item),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${currencyFormat.format(item.price)}원',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.download_for_offline,
                                  color: Colors.blueGrey,
                                  size: 40,
                                ),
                                onPressed: () {
                                  if (item.options.isNotEmpty) {
                                    Get.bottomSheet(
                                      MenuOptionBottomSheet(
                                        item: item,
                                        mode: OptionMode.addToCart,
                                      ),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );
                                  } else {
                                    controller.addToCart(item);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildMenuItemImage(item.images),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMenuItemImage(List<String>? images) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (images != null && images.isNotEmpty)
              Image.network(
                images[0],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  );
                },
              )
            else
              Center(
                child: Icon(
                  Icons.restaurant,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
            if (images != null && images.length > 1)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${images.length - 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// class CartIconButton extends StatelessWidget {
//   final int itemCount;
//   final VoidCallback onPressed;

//   const CartIconButton({
//     super.key,
//     required this.itemCount,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       backgroundColor: Colors.grey[500],
//       onPressed: onPressed,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           const Icon(
//             Icons.shopping_bag,
//             size: 40,
//             color: Colors.white,
//           ),
//           if (itemCount > 0)
//             Positioned(
//               right: 10,
//               top: 15,
//               child: Container(
//                 padding: const EdgeInsets.all(1),
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 constraints: const BoxConstraints(
//                   minWidth: 16,
//                   minHeight: 16,
//                 ),
//                 child: Text(
//                   itemCount.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
