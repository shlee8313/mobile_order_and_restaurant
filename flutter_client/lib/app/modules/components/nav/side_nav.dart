import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/sidebar_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/theme/app_theme.dart';
import '../../../controllers/business_day_controller.dart';

class SideNav extends GetView<SidebarController> {
  final AuthController authController = Get.find<AuthController>();
  final NavigationController navigationController =
      Get.find<NavigationController>();
  final BusinessDayController businessDayController =
      Get.find<BusinessDayController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: controller.isExpanded ? 250 : 60,
          decoration: BoxDecoration(
            color: AppTheme.navBarColor,
            border: Border(
              right: BorderSide(color: AppTheme.navBarBorderColor!),
              bottom: BorderSide(color: AppTheme.navBarBorderColor!),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMenu()),
              _buildEndBusinessDayButton(context),
            ],
          ),
        ));
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: controller.isExpanded
          ? _buildExpandedHeader()
          : _buildCollapsedHeader(),
    );
  }

  Widget _buildExpandedHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth - 46; // 38 for toggle button, 8 for padding
        final showIcon =
            availableWidth > 180; // Only show icon if there's enough space

        return Row(
          children: [
            SizedBox(width: 8),
            if (showIcon) ...[
              Icon(Icons.restaurant, color: Colors.grey[600]),
              SizedBox(width: 8),
            ],
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  authController.restaurant.value?.businessName ?? '레스토랑',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _buildToggleButton(),
            SizedBox(width: 8),
          ],
        );
      },
    );
  }

  Widget _buildCollapsedHeader() {
    return Center(child: _buildToggleButton());
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: controller.toggleSidebar,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(
          controller.isExpanded ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Obx(() {
      final hasTables = authController.restaurant.value?.hasTables ?? false;
      return ListView(
        children: [
          if (hasTables) ...[
            _buildMenuItem(Icons.table_restaurant, '주문내역', Routes.ADMINORDER),
            _buildMenuItem(Icons.attach_money, '매출내역', Routes.SALES),
            _buildMenuItem(Icons.credit_card, '결제내역', Routes.PAYMENTS),
            _buildMenuItem(Icons.menu_book, '메뉴관리', Routes.MENUEDIT),
            _buildMenuItem(Icons.person, '내 정보', Routes.PROFILE),
            _buildMenuItem(Icons.qr_code, 'QR 생성', Routes.QR_GENERATE),
            _buildMenuItem(Icons.edit, '테이블 위치 변경', Routes.TABLE_EDIT),
          ] else ...[
            _buildMenuItem(Icons.flash_on, '빠른 주문', Routes.QUICK_ORDER),
            _buildMenuItem(Icons.attach_money, '매출내역', Routes.SALES),
            _buildMenuItem(Icons.credit_card, '결제내역', Routes.PAYMENTS),
            _buildMenuItem(Icons.menu_book, '메뉴관리', Routes.MENUEDIT),
            _buildMenuItem(Icons.person, '내 정보', Routes.PROFILE),
            _buildMenuItem(Icons.qr_code, 'QR 생성', Routes.QR_GENERATE),
          ],
        ],
      );
    });
  }

  Widget _buildMenuItem(IconData icon, String title, String route) {
    bool isActive = navigationController.currentPage.value == title;
    return Obx(() => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          leading: Icon(icon, color: isActive ? Colors.blue : Colors.grey[600]),
          title: controller.isExpanded
              ? Text(
                  title,
                  style:
                      TextStyle(color: isActive ? Colors.blue : Colors.black),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          tileColor: isActive ? Colors.blue.withOpacity(0.1) : null,
          onTap: () {
            Get.toNamed(route, id: Routes.ADMIN_ID);
            navigationController.setCurrentPage(title);
          },
        ));
  }

  Widget _buildEndBusinessDayButton(BuildContext context) {
    return Obx(() => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          leading: Icon(
            businessDayController.isBusinessDayActive.value
                ? Icons.exit_to_app
                : Icons.refresh,
            color: businessDayController.isBusinessDayActive.value
                ? Colors.red
                : Colors.green,
          ),
          title: controller.isExpanded
              ? Text(
                  businessDayController.isBusinessDayActive.value
                      ? '영업마감'
                      : '영업마감 해제',
                  style: TextStyle(
                    color: businessDayController.isBusinessDayActive.value
                        ? Colors.red
                        : Colors.green,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () => businessDayController.isBusinessDayActive.value
              ? _showEndBusinessDayDialog(context)
              : _showCancelEndBusinessDayDialog(context),
        ));
  }

  void _showEndBusinessDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('영업 마감'),
          content: Text('영업마감후 더 이상 주문을 받을 수 없습니다. 영업을 종료하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                businessDayController.endBusinessDay(
                    authController.restaurant.value?.restaurantId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCancelEndBusinessDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('영업마감 해제'),
          content: Text('영업마감을 해제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                businessDayController.cancelEndBusinessDay(
                    authController.restaurant.value?.restaurantId);
              },
            ),
          ],
        );
      },
    );
  }
}
