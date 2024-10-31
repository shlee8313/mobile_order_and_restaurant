// File: lib/models/daily_sales.dart
import 'package:mongo_dart/mongo_dart.dart';

class DailySales {
  final String restaurantId;
  final String businessDayId;
  final DateTime date;
  final int totalSales;
  final List<ItemSales> itemSales; // Changed from 'items' to 'itemSales'

  DailySales({
    required this.restaurantId,
    required this.businessDayId,
    required this.date,
    required this.totalSales,
    required this.itemSales,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      restaurantId: json['restaurantId'] ?? '',
      businessDayId: json['businessDayId']?.toString() ?? '',
      date: _parseDate(json['date']),
      totalSales: _parseNumber(json['totalSales']),
      itemSales: (json['itemSales'] as List<dynamic>?)
              ?.map((item) => ItemSales.fromJson(item))
              .toList() ??
          [],
    );
  }

  static DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    if (dateData is String) return DateTime.parse(dateData);
    if (dateData is Map && dateData['\$date'] != null) {
      final timestamp = dateData['\$date']['\$numberLong'];
      if (timestamp is String) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }
    return DateTime.now();
  }

  static int _parseNumber(dynamic number) {
    if (number is int) return number;
    if (number is String) return int.tryParse(number) ?? 0;
    if (number is Map && number['\$numberInt'] != null) {
      return int.tryParse(number['\$numberInt'].toString()) ?? 0;
    }
    return 0;
  }
}

class ItemSales {
  final String itemId;
  final String name;
  final int price;
  final int quantity;
  final int sales;

  ItemSales({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.sales,
  });

  factory ItemSales.fromJson(Map<String, dynamic> json) {
    return ItemSales(
      itemId: json['itemId'] ?? '',
      name: json['name'] ?? '',
      price: _parseNumber(json['price']),
      quantity: _parseNumber(json['quantity']),
      sales: _parseNumber(json['sales']),
    );
  }

  static int _parseNumber(dynamic number) {
    if (number is int) return number;
    if (number is String) return int.tryParse(number) ?? 0;
    if (number is Map && number['\$numberInt'] != null) {
      return int.tryParse(number['\$numberInt'].toString()) ?? 0;
    }
    return 0;
  }
}
