// lib/services/restaurant_service.dart

import 'package:get/get.dart';
import '../models/restaurant.dart';
import '../models/menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/api_config.dart';

class RestaurantService extends GetxService {
  // 레스토랑 정보 가져오기
  Future<Restaurant?> getRestaurantInfo(String restaurantId) async {
    try {
      final url = '${ApiConfig.restaurants}?restaurantId=$restaurantId';
      print('Fetching restaurant info from: $url');

      final response = await http.get(Uri.parse(url));

      print('Restaurant API Response Status Code: ${response.statusCode}');
      print('Restaurant API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final restaurantData = json.decode(response.body);
        print('Decoded restaurant data: $restaurantData');
        return Restaurant.fromJson(restaurantData);
      } else {
        print(
            'Failed to load restaurant info. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getRestaurantInfo: $e');
      return null;
    }
  }

  // 레스토랑 메뉴 가져오기 (menu API 사용)
  Future<Menu?> getRestaurantMenu(String restaurantId) async {
    try {
      final url = '${ApiConfig.menu}?restaurantId=$restaurantId';
      // print('Fetching menu from: $url');

      final response = await http.get(Uri.parse(url));

      // print('Menu API Response Status Code: ${response.statusCode}');
      // print('Menu API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final menuData = json.decode(response.body);
        // print('Decoded menu data: $menuData');
        return Menu.fromJson(menuData);
      } else {
        print('Failed to load menu. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getRestaurantMenu: $e');
      return null;
    }
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final url = ApiConfig.restaurants;
      print('Fetching all restaurants from: $url');

      final response = await http.get(Uri.parse(url));

      print('All Restaurants API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> restaurantsData = json.decode(response.body);
        return restaurantsData
            .map((data) => Restaurant.fromJson(data))
            .toList();
      } else {
        print(
            'Failed to load restaurants. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in getAllRestaurants: $e');
      return [];
    }
  }
}
