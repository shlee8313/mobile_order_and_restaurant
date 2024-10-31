// File: lib/controllers/sidebar_controller.dart
import 'package:get/get.dart';

class SidebarController extends GetxController {
  final RxBool _isExpanded = true.obs;

  bool get isExpanded => _isExpanded.value;

  void toggleSidebar() {
    _isExpanded.toggle();
  }
}
