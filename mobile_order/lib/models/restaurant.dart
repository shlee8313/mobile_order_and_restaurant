// file: /models/restaurant.dart

import 'package:get/get.dart';

class Restaurant {
  final String id;
  final String email;
  final String restaurantId;
  final String businessName;
  final String address;
  final String phoneNumber;
  final String businessNumber;
  final String? operatingHours;
  final bool hasTables;
  final int? tables;
  final List<String> orders;
  final List<String> quickOrders;
  final int totalVisits;
  final int totalLikes;
  final String? avatarImage; // 아바타 이미지 URL
  final String? coverImage; // 레스토랑 전체 이미지 URL
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Restaurant({
    required this.id,
    required this.email,
    required this.restaurantId,
    required this.businessName,
    required this.address,
    required this.phoneNumber,
    required this.businessNumber,
    this.operatingHours,
    required this.hasTables,
    this.tables,
    required this.orders,
    required this.quickOrders,
    this.totalVisits = 0,
    this.totalLikes = 0,
    this.avatarImage, // 초기화
    this.coverImage, // 초기화
    this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      businessNumber: json['businessNumber']?.toString() ?? '',
      operatingHours: json['operatingHours']?.toString(),
      hasTables: json['hasTables'] == true,
      tables: json['tables'] is int ? json['tables'] : null,
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      quickOrders: (json['quickOrders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalVisits: json['totalVisits'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      avatarImage: json['avatarImage']?.toString(), // 추가
      coverImage: json['coverImage']?.toString(), // 추가
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
      'restaurantId': restaurantId,
      'businessName': businessName,
      'address': address,
      'phoneNumber': phoneNumber,
      'businessNumber': businessNumber,
      'operatingHours': operatingHours,
      'hasTables': hasTables,
      'tables': tables,
      'orders': orders,
      'quickOrders': quickOrders,
      'totalVisits': totalVisits, // 'visitCount' 대신
      'totalLikes': totalLikes, // 'likeCount' 대신
      'avatarImage': avatarImage, // 추가
      'coverImage': coverImage, // 추가
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Extension for reactive properties
extension ReactiveRestaurant on Restaurant {
  RxString get rxBusinessName => businessName.obs;
  RxBool get rxHasTables => hasTables.obs;
  RxInt? get rxTables => tables?.obs;
  RxInt get rxTotalVisits => totalVisits.obs;
  RxInt get rxTotalLikes => totalLikes.obs;
  RxList<String> get rxOrders => orders.obs;
  RxList<String> get rxQuickOrders => quickOrders.obs;
  RxString? get rxAvatarImage => avatarImage?.obs; // 추가
  RxString? get rxCoverImage => coverImage?.obs; // 추가
}
