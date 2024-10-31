// file: lib/app/data/models/user.dart

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

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
  final String uid;
  final String email;
  String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  final String role;
  final List<UserMeal> meals;
  final List<Visit> visits;
  final List<String>? likedRestaurants;
  final List<String>? coupons;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    this.phoneNumber,
    this.role = 'customer',
    this.meals = const [],
    this.visits = const [],
    this.likedRestaurants,
    this.coupons,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      phoneNumber: firebaseUser.phoneNumber,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString(),
      photoURL: json['photoURL']?.toString(),
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber']?.toString(),
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
      coupons: (json['coupons'] as List<dynamic>?)
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
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'role': role,
      'visits': visits.map((visit) => visit.toJson()).toList(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'likedRestaurants': likedRestaurants,
      'coupons': coupons,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => displayName ?? email;
}

// Extension for reactive properties
extension ReactiveUser on User {
  RxString get rxFullName => fullName.obs;
  RxList<UserMeal> get rxMeals => meals.obs;
  RxList<Visit> get rxVisits => visits.obs;
  RxList<String>? get rxLikedRestaurants => likedRestaurants?.obs;
  RxList<String>? get rxCoupons => coupons?.obs;
}
