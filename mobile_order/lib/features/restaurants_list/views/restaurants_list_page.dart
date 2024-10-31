// lib/features/restaurants/views/restaurants_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurants_list_controller.dart';

class RestaurantsListPage extends GetView<RestaurantsListController> {
  const RestaurantsListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Restaurants list')),
        body: const Center(
          child: Text(' Restaurants list'),
        ));
  }
}
