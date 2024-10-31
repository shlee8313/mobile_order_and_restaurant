// lib/features/restaurants/controllers/restaurants_list_controller.dart

import 'package:get/get.dart';
import '../../../models/restaurant.dart';
import '../../../services/restaurant_service.dart';

class RestaurantsListController extends GetxController {
  final RestaurantService _restaurantService = Get.find<RestaurantService>();

  final RxList<Restaurant> restaurants = <Restaurant>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    try {
      isLoading.value = true;
      restaurants.value = await _restaurantService.getAllRestaurants();
    } catch (e) {
      print('Error fetching restaurants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showRestaurantDetails(String restaurantId) {
    // Navigate to a detailed view of the restaurant if needed
    // This could be a new page showing more info about the restaurant
    Get.toNamed('/restaurant-details',
        arguments: {'restaurantId': restaurantId});
  }
}
