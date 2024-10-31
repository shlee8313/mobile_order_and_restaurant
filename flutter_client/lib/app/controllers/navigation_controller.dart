// file: lib/app/controllers/navigation_controller.dart

import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentPage = 'Admin Dashboard'.obs;

  void setCurrentPage(String page) {
    currentPage.value = page;
  }

  // New method to reset to the default page
  // void resetToAdminDashboard() {
  //   currentPage.value = 'Admin Dashboard';
  // }
}
