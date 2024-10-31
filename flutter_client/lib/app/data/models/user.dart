// file: lib/app/data/models/user.dart

import 'package:get/get.dart';

class Visit {
  final String restaurantId;
  final int count;

  Visit({required this.restaurantId, required this.count});

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      restaurantId: json['restaurant']?.toString() ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurantId,
      'count': count,
    };
  }
}

class UserMeal {
  final String restaurantId;
  final DateTime date;
  final List<MealItem> items;
  final double totalAmount;

  UserMeal({
    required this.restaurantId,
    required this.date,
    required this.items,
    required this.totalAmount,
  });

  factory UserMeal.fromJson(Map<String, dynamic> json) {
    return UserMeal(
      restaurantId: json['restaurantId'] ?? '',
      date: DateTime.parse(json['date']),
      items: (json['items'] as List<dynamic>)
          .map((item) => MealItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}

class MealItem {
  final String name;
  final int quantity;
  final double price;

  MealItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final List<UserMeal> meals;
  final List<Visit> visits;
  final List<String>? likedRestaurants;
  final List<String>? coupons; // 추가: 쿠폰 ID 목록
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.meals,
    required this.visits,
    this.likedRestaurants,
    this.coupons, // 추가
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      meals: (json['meals'] as List<dynamic>?)
              ?.map((meal) => UserMeal.fromJson(meal))
              .toList() ??
          [],
      visits: (json['visits'] as List<dynamic>?)
              ?.map((visit) => Visit.fromJson(visit))
              .toList() ??
          [],
      likedRestaurants: (json['likedRestaurants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      coupons: (json['coupons'] as List<dynamic>?) // 추가
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'visits': visits.map((visit) => visit.toJson()).toList(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'likedRestaurants': likedRestaurants,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

// Extension for reactive properties
extension ReactiveUser on User {
  RxString get rxFullName => fullName.obs;
  RxList<UserMeal> get rxMeals => meals.obs;
  RxList<Visit> get rxVisits => visits.obs;
  RxList<String>? get rxLikedRestaurants => likedRestaurants?.obs;
  RxList<String>? get rxCoupons => coupons?.obs; // 추가
}
