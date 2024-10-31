// file: lib/app/routes/app_routes.dart
import '../modules/admin/dashboard/dashboard_view.dart';
import '../modules/admin/admin_order/admin_order_view.dart';
import '../modules/admin/sales/sales_view.dart';
import '../modules/admin/payments/payments_view.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/admin/profile/profile_view.dart';
import '../modules/admin/qr_generate/qr_generate_view.dart';
import '../modules/admin/table_edit/table_edit_view.dart';
import '../modules/admin/quick_order/quick_order_view.dart';
import '../modules/admin/edit_menu/menu_edit_view.dart';

abstract class Routes {
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const ADMIN = '/admin';
  static const DASHBOARD = "/dashboard";
  static const ADMINORDER = '/admin-order';
  static const SALES = '/sales';
  static const PAYMENTS = '/payments';
  static const MENUEDIT = '/menu-edit';
  static const PROFILE = '/profile';
  static const QR_GENERATE = '/qr-generate';
  static const TABLE_EDIT = '/table-edit';
  static const QUICK_ORDER = '/quick-order';

  // Nested navigation IDs
  static const int ADMIN_ID = 1;
}
