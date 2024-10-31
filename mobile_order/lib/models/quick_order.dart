// import 'package:meta/meta.dart';

class SelectedOption {
  final String name; // 옵션 이름 (예: "샷 추가")
  final String choice; // 사용자가 선택한 옵션 값 (예: "추가")
  final int price; // 선택지에 따른 추가 가격
  final int? quantity; // 선택지에 따른 수량

  SelectedOption({
    required this.name,
    required this.choice,
    required this.price, // 가격을 int로 설정
    this.quantity, // 수량은 nullable
  });

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'],
      choice: json['choice'],
      price: json['price'] as int, // int로 변환
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

class QuickOrderItem {
  final String id;
  final String name;
  final int price;
  final int quantity;
  final bool isComplimentary;
  final List<SelectedOption> selectedOptions; // 선택된 옵션 목록
  const QuickOrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.isComplimentary = false,
    this.selectedOptions = const [], // 기본값으로 빈 목록
  });

  factory QuickOrderItem.fromJson(Map<String, dynamic> json) {
    return QuickOrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      quantity: json['quantity'] as int,
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

  QuickOrderItem copyWith({
    String? id,
    String? name,
    int? price, // double에서 int로 변경
    int? quantity,
    bool? isComplimentary,
  }) {
    return QuickOrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isComplimentary: isComplimentary ?? this.isComplimentary,
    );
  }
}

class QuickOrder {
  final String id;
  final String restaurantId;
  final String businessDayId; // 추가된 필드
  final int? orderNumber;
  final List<QuickOrderItem> items;
  int queuePosition; // final 제거
  String status; // final 제거
  final int totalAmount;
  final bool isComplimentaryOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String user; // 사용자 참조를 위한 ID
  final String? fcmToken; // FCM 토큰 필드 추가
  QuickOrder({
    required this.id,
    required this.restaurantId,
    required this.businessDayId, // 생성자에 추가
    this.orderNumber,
    required this.items,
    this.queuePosition = 0,
    this.status = 'pending',
    required this.totalAmount,
    this.isComplimentaryOrder = false,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.fcmToken, // 생성자에 추가
  });

  factory QuickOrder.fromJson(Map<String, dynamic> json) {
    return QuickOrder(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      businessDayId: json['businessDayId']?.toString() ?? '',
      orderNumber: json['orderNumber'] != null
          ? int.tryParse(json['orderNumber'].toString())
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  QuickOrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      queuePosition: int.tryParse(json['queuePosition']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      totalAmount: int.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
      isComplimentaryOrder: json['isComplimentaryOrder'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: json['user']?.toString() ?? '',
      fcmToken: json['fcmToken']?.toString(), // JSON 파싱에 추가
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'businessDayId': businessDayId, // JSON 변환에 추가
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'queuePosition': queuePosition,
      'status': status,
      'totalAmount': totalAmount,
      'isComplimentaryOrder': isComplimentaryOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user,
      'fcmToken': fcmToken, // JSON 변환에 추가
    };
  }

  QuickOrder copyWith({
    String? id,
    String? restaurantId,
    String? businessDayId, // copyWith에 추가
    int? orderNumber,
    List<QuickOrderItem>? items,
    int? queuePosition,
    String? status,
    int? totalAmount,
    bool? isComplimentaryOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? user,
    String? fcmToken, // copyWith에 추가
  }) {
    return QuickOrder(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      businessDayId: businessDayId ?? this.businessDayId, // copyWith 메서드에 추가
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      queuePosition: queuePosition ?? this.queuePosition,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      isComplimentaryOrder: isComplimentaryOrder ?? this.isComplimentaryOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      fcmToken: fcmToken ?? this.fcmToken, // copyWith에 추가
    );
  }
}
