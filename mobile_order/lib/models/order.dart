//file: \lib\models\order.dart

class SelectedOption {
  final String name; // 옵션 이름 (예: "샷 추가")
  final String choice; // 사용자가 선택한 옵션 값 (예: "추가")
  final int? price; // 선택지에 따른 추가 가격
  final int? quantity; // 선택지에 따른 수량

  SelectedOption({
    required this.name,
    required this.choice,
    this.price, // 가격을 int로 설정
    this.quantity, // 수량은 nullable
  });

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'],
      choice: json['choice'],
      price: json['price'] as int?, // int로 변환
      quantity: json['quantity'] as int?, // nullable로 변환
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choice': choice,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderItem {
  final String id;
  final String name;
  final int price;
  final int quantity;
  final bool isComplimentary;
  final List<SelectedOption> selectedOptions; // 선택된 옵션 목록

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.isComplimentary = false,
    this.selectedOptions = const [], // 기본값으로 빈 목록
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      price: json['price'] as int,
      quantity: json['quantity'],
      isComplimentary: json['isComplimentary'] ?? false,
      selectedOptions: (json['selectedOptions'] as List<dynamic>?)
              ?.map((option) =>
                  SelectedOption.fromJson(option as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isComplimentary': isComplimentary,
      'selectedOptions':
          selectedOptions.map((option) => option.toJson()).toList(),
    };
  }
}

class Order {
  final String? id;
  final String restaurantId;
  final String businessDayId; // 필수 필드로 변경
  final int tableId;
  final List<OrderItem> items;
  final String status;
  final int totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isComplimentaryOrder;
  final String user;

  Order({
    this.id,
    required this.restaurantId,
    required this.businessDayId, // 필수 매개변수로 변경
    required this.tableId,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.isComplimentaryOrder = false,
    required this.user,
  });

  Order copyWith({
    String? id,
    String? restaurantId,
    String? businessDayId,
    int? tableId,
    List<OrderItem>? items,
    String? status,
    int? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isComplimentaryOrder,
    String? user,
  }) {
    return Order(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      businessDayId: businessDayId ?? this.businessDayId,
      tableId: tableId ?? this.tableId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isComplimentaryOrder: isComplimentaryOrder ?? this.isComplimentaryOrder,
      user: user ?? this.user,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      restaurantId: json['restaurantId'],
      businessDayId: json['businessDayId'],
      tableId: json['tableId'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: json['status'],
      totalAmount: json['totalAmount'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isComplimentaryOrder: json['isComplimentaryOrder'] ?? false,
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'restaurantId': restaurantId,
      'businessDayId': businessDayId,
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isComplimentaryOrder': isComplimentaryOrder,
      'user': user,
    };
  }
}
