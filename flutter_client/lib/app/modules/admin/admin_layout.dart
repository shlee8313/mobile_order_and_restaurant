// file: lib/app/modules/admin/admin_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_client/app/modules/admin/dashboard/dashboard_view.dart';
import 'package:get/get.dart';
import '../components/nav/side_nav.dart';
import '../components/nav/top_bar.dart';
import '../../routes/app_routes.dart';
import "../../modules/admin/dashboard/dashboard_view.dart";
import '../../modules/admin/admin_order/admin_order_view.dart';
import '../../modules/admin/sales/sales_view.dart';
import '../../modules/admin/payments/payments_view.dart';

import '../../modules/admin/profile/profile_view.dart';
import '../../modules/admin/qr_generate/qr_generate_view.dart';
import '../../modules/admin/table_edit/table_edit_view.dart';
import '../../modules/admin/quick_order/quick_order_view.dart';
import '../../modules/admin/edit_menu/menu_edit_view.dart';

class AdminLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNav(),
          Expanded(
            child: Column(
              children: [
                TopBar(),
                Expanded(
                  child: Navigator(
                    key: Get.nestedKey(Routes.ADMIN_ID),
                    initialRoute: Routes.DASHBOARD,
                    onGenerateRoute: (settings) {
                      return GetPageRoute(
                        settings: settings,
                        page: () {
                          switch (settings.name) {
                            case Routes.DASHBOARD:
                              return DashboardView();
                            case Routes.ADMINORDER:
                              return AdminOrderView();
                            case Routes.SALES:
                              return SalesView();
                            case Routes.PAYMENTS:
                              return PaymentsView();
                            case Routes.MENUEDIT:
                              return MenuEditView();
                            case Routes.PROFILE:
                              return ProfileView();
                            case Routes.QR_GENERATE:
                              return QrGenerateView();
                            case Routes.TABLE_EDIT:
                              return TableEditView();
                            case Routes.QUICK_ORDER:
                              return QuickOrderView();
                            default:
                              return DashboardView();
                          }
                        },
                        transition: Transition.fadeIn,
                        transitionDuration: Duration(milliseconds: 100),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
