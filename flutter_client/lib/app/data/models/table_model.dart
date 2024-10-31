// File: lib/models/table_model.dart
import 'package:get/get.dart';
import './order.dart';

class TableModel {
  final String id;
  final int tableId;
  final double x;
  final double y;
  final double width;
  final double height;
  final String status;
  final RxList<Order> orders;

  TableModel({
    required this.id,
    required this.tableId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.status = 'empty',
    List<Order>? orders,
  }) : this.orders = (orders ?? []).obs;

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['_id'],
      tableId: json['tableId'],
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 100).toDouble(),
      height: (json['height'] ?? 100).toDouble(),
      status: json['status'] ?? 'empty',
      orders: (json['orders'] as List?)
              ?.map((order) => Order.fromJson(order))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // 여기를 '_id'로 변경
      'tableId': tableId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'status': status,
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}
