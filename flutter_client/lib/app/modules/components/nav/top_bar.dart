// file: lib/app/modules/components/nav/top_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/sales_controller.dart';
import '../../../ui/theme/app_theme.dart';
import 'package:intl/intl.dart';

/**
 * 
 */
class TopBar extends GetView<NavigationController> {
  final AuthController authController = Get.find<AuthController>();
  final SalesController salesController = Get.find<SalesController>();

  TopBar() {
    // Fetch today's sales when the TopBar is initialized
    _fetchSalesData();
  }

  void _fetchSalesData() {
    final restaurantToken = authController.restaurantToken.value;
    final restaurant = authController.restaurant.value;

    if (restaurantToken != null && restaurant != null) {
      salesController.fetchTodaySales(
        restaurant.restaurantId, // Assuming restaurant has an id property
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.navBarColor,
        border: Border(
          left: BorderSide(color: AppTheme.navBarBorderColor!),
          bottom: BorderSide(color: AppTheme.navBarBorderColor!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Obx(() => Text(
                  controller.currentPage.value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
          ),
          Row(
            children: [
              Obx(() {
                final todaySales = salesController.todaySales?.totalSales ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '오늘의 매출: ${_formatNumber(todaySales)}원',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    authController.fullLogout();
                    Get.offAllNamed('/login');
                  },
                  child: Text('로그아웃'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/**
 * 
 */
String _formatNumber(num number) {
  return NumberFormat('#,###').format(number);
}
