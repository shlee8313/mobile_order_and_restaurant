// file: lib/app/routes/app_pages.dart

import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import "../modules/admin/admin_binding.dart";
import '../modules/admin/admin_order/admin_order_binding.dart';
import '../modules/admin/dashboard/dashboard_view.dart';
import '../modules/admin/admin_layout.dart';
import '../modules/admin/admin_order/admin_order_view.dart';
import '../modules/admin/sales/sales_view.dart';
import '../modules/admin/payments/payments_view.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/auth/register/register_binding.dart';
import '../controllers/menu_edit_controller.dart';
import '../modules/admin/edit_menu/menu_edit_view.dart';
import '../modules/admin/edit_menu/menu_edit_binding.dart';
import '../modules/admin/profile/profile_view.dart';
import '../modules/admin/qr_generate/qr_generate_view.dart';
import '../modules/admin/table_edit/table_edit_view.dart';
import '../modules/admin/quick_order/quick_order_view.dart';
import '../modules/admin/quick_order/quick_order_binding.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: '/register',
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.ADMIN,
      page: () => AdminLayout(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware()],
      children: [
        GetPage(
          name: Routes.DASHBOARD,
          page: () => DashboardView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.ADMINORDER,
          page: () => AdminOrderView(),
          binding: AdminOrderBinding(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.SALES,
          page: () => SalesView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.PAYMENTS,
          page: () => PaymentsView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.MENUEDIT,
          page: () => MenuEditView(),
          binding: MenuEditBinding(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.PROFILE,
          page: () => ProfileView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.QR_GENERATE,
          page: () => QrGenerateView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.TABLE_EDIT,
          page: () => TableEditView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: Routes.QUICK_ORDER,
          page: () => QuickOrderView(),
          transition: Transition.fadeIn,
        ),
      ],
    ),
  ];
}
