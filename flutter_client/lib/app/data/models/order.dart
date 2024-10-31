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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      isComplimentary: json['isComplimentary'] as bool? ?? false,
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
  final String id;
  final String restaurantId;
  final String? businessDayId; // 추가: businessDayId 필드
  // final int? tableId; // 주석 처리
  final int tableId; // 원래 코드로 복원
  final List<OrderItem> items;
  final String status;
  final int totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isComplimentaryOrder;
  final String user; // 사용자 참조를 위한 ID
  // final int? orderNumber; // 선택적 매개변수
  // final int queuePosition; // orderNumber 대신 queuePosition 추가

  Order({
    required this.id,
    required this.restaurantId,
    this.businessDayId, // 추가: 생성자에 businessDayId 포함
    // this.tableId, // 주석 처리
    required this.tableId, // 원래 코드로 복원
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.isComplimentaryOrder = false,
    required this.user,
    // this.orderNumber, // 다시 추가된 부분
    // required this.queuePosition, // queuePosition 필수 매개변수로 추가
  });

  Order copyWith({
    String? id,
    String? restaurantId,
    String? businessDayId, // 추가: copyWith 메서드에 businessDayId 포함
    int? tableId,
    List<OrderItem>? items,
    String? status,
    int? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isComplimentaryOrder,
    String? user,
    // int? orderNumber, // 다시 추가된 부분
  }) {
    return Order(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      businessDayId: businessDayId ??
          this.businessDayId, // 추가: copyWith에서 businessDayId 처리
      tableId: tableId ?? this.tableId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isComplimentaryOrder: isComplimentaryOrder ?? this.isComplimentaryOrder,
      user: user ?? this.user,
      // orderNumber: orderNumber ?? this.orderNumber, // 다시 추가된 부분
      // queuePosition: queuePosition ?? this.queuePosition,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      businessDayId: json['businessDayId']?.toString(),
      tableId: int.tryParse(json['tableId']?.toString() ?? '0') ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status']?.toString() ?? 'pending',
      totalAmount: int.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isComplimentaryOrder: json['isComplimentaryOrder'] as bool? ?? false,
      user: json['user']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'businessDayId': businessDayId, // 추가: JSON 변환 시 businessDayId 포함
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isComplimentaryOrder': isComplimentaryOrder,
      'user': user,
      // 'orderNumber': orderNumber, // 다시 추가된 부분
      // 'queuePosition': queuePosition,
    };
  }
}
