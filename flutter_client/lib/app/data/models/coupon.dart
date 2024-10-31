// file: lib/app/data/models/coupon.dart
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class Coupon {
  final String id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double minPurchase;
  final double? maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int usageLimit;
  final int usedCount;
  final String? restaurantId;
  final List<String> applicableItems;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.usageLimit,
    required this.usedCount,
    this.restaurantId,
    required this.applicableItems,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minPurchase: (json['minPurchase'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: DateTime.parse(json['endDate'].toString()),
      isActive: json['isActive'] as bool? ?? true,
      usageLimit: json['usageLimit'] as int? ?? 1,
      usedCount: json['usedCount'] as int? ?? 0,
      restaurantId: json['restaurantId']?.toString(),
      applicableItems: (json['applicableItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchase': minPurchase,
      'maxDiscount': maxDiscount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'restaurantId': restaurantId,
      'applicableItems': applicableItems,
    };
  }
}

// Extension for reactive properties
extension ReactiveCoupon on Coupon {
  RxString get rxCode => code.obs;
  RxBool get rxIsActive => isActive.obs;
  RxInt get rxUsedCount => usedCount.obs;
}
