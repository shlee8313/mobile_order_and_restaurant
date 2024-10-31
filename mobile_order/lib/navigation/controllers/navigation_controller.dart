// lib/navigation/controllers/navigation_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NavigationController extends GetxController {
  final _currentIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  int get currentIndex => _currentIndex.value;

  void changePage(int index) {
    print('Changing page to index: $index'); // Debug log
    _currentIndex.value = index;
  }

  void animateToPage(int index) {
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void resetNavigation() {
    _currentIndex.value = 0;
    // pageController.jumpToPage(0);
  }
}
