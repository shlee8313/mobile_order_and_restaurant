// file: lib/app/modules/admin/admin_controller.dart

import 'package:get/get.dart';

class AdminController extends GetxController {
  // 여기에 관리자 페이지에 필요한 상태와 메서드를 추가합니다.
  final RxString currentPage = ''.obs;

  void setCurrentPage(String page) {
    currentPage.value = page;
  }
}
