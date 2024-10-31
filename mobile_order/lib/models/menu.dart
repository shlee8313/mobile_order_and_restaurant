// File: \lib\models\menu.dart

// import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// class MenuItemOption {
//   final String name; // 옵션 이름 (예: 설탕추가, 고추빼고)
//   final List<Choice> choices; // 선택지 목록
//   final String? defaultChoice; // 기본 선택값
//   final bool isRequired; // 필수 선택 여부

//   MenuItemOption({
//     required this.name,
//     required this.choices,
//     this.defaultChoice,
//     this.isRequired = false,
//   });

//   factory MenuItemOption.fromJson(Map<String, dynamic> json) {
//     return MenuItemOption(
//       name: json['name'] ?? 'Unknown Option',
//       choices: (json['choices'] as List<dynamic>)
//           .map((choice) => Choice.fromJson(choice as Map<String, dynamic>))
//           .toList(),
//       defaultChoice: json['defaultChoice'],
//       isRequired: json['isRequired'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'choices': choices.map((choice) => choice.toJson()).toList(),
//       'defaultChoice': defaultChoice,
//       'isRequired': isRequired,
//     };
//   }
// }

class MenuItemOption {
  final String name;
  final List<Choice> choices;
  final String? defaultChoice;
  final bool isRequired;
  final bool isMultiple; // 주석: 다중 선택 가능 여부 추가

  MenuItemOption({
    required this.name,
    required this.choices,
    this.defaultChoice,
    this.isRequired = false,
    this.isMultiple = false, // 주석: 기본값은 단일 선택
  });

  factory MenuItemOption.fromJson(Map<String, dynamic> json) {
    return MenuItemOption(
      name: json['name'] ?? 'Unknown Option',
      choices: (json['choices'] as List<dynamic>)
          .map((choice) => Choice.fromJson(choice as Map<String, dynamic>))
          .toList(),
      defaultChoice: json['defaultChoice'],
      isRequired: json['isRequired'] ?? false,
      isMultiple: json['isMultiple'] ?? false, // 주석: JSON에서 다중 선택 여부 파싱
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'defaultChoice': defaultChoice,
      'isRequired': isRequired,
      'isMultiple': isMultiple, // 주석: JSON에 다중 선택 여부 포함
    };
  }
}

class Choice {
  final String name; // 선택지 이름
  final int price; // 선택지에 따른 추가 가격
  final int? quantity; // 선택지에 따른 수량 (없을 수 있음)

  Choice({
    required this.name,
    this.price = 0, // 기본값 0
    this.quantity, // 선택적
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      name: json['name'] ?? 'Unknown Choice',
      price: json['price'] ?? 0,
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final String? description;
  final String? detailedDescription;
  final int price;
  final List<String> images; // Changed from String? to List<String>
  final bool isVisible;
  final bool isTakeout;
  final List<MenuItemOption> options; // 추가된 옵션 목록
  final int? discountAmount; // 추가: 할인 금액 (없을 수 있음)
  final int? rewardPoints; // 추가: 적립 포인트 (없을 수 있음)
  final Map<String, List<String>>
      selectedOptions; // 주석: String -> List<String>으로 변경

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.detailedDescription,
    required this.price,
    this.images = const [], // Default to empty list
    this.isVisible = true,
    this.isTakeout = false,
    this.options = const [], // Default to empty list
    this.discountAmount, // 추가
    this.rewardPoints, // 추가
    this.selectedOptions = const {}, // 기본값으로 빈 Map 설정
  });

  factory MenuItem.create({
    required String name,
    String? description,
    String? detailedDescription,
    required int price,
    List<String> images = const [],
    bool isVisible = true,
    bool isTakeout = false,
    List<MenuItemOption> options = const [], // 추가된 옵션 목록
    int? discountAmount, // 추가
    int? rewardPoints, // 추가
  }) {
    return MenuItem(
      id: const Uuid().v4(),
      name: name,
      description: description,
      detailedDescription: detailedDescription,
      price: price,
      images: images,
      isVisible: isVisible,
      isTakeout: isTakeout,
      options: options, // 추가된 옵션 목록
      discountAmount: discountAmount, // 추가
      rewardPoints: rewardPoints, // 추가
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    String? detailedDescription,
    int? price,
    List<String>? images, // Changed from String? to List<String>?
    bool? isVisible,
    bool? isTakeout,
    List<MenuItemOption>? options, // 추가된 옵션 목록
    int? discountAmount, // 추가
    int? rewardPoints, // 추가
    Map<String, List<String>>? selectedOptions,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      price: price ?? this.price,
      images: images ?? this.images,
      isVisible: isVisible ?? this.isVisible,
      isTakeout: isTakeout ?? this.isTakeout,
      options: options ?? this.options, // 추가된 옵션 목록
      discountAmount: discountAmount ?? this.discountAmount, // 추가
      rewardPoints: rewardPoints ?? this.rewardPoints, // 추가
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? 'Unknown',
      description: json['description'],
      detailedDescription: json['detailedDescription'],
      price: json['price'] as int, // 수정: 단순히 int로 캐스팅
      images: (json['images'] as List<dynamic>?)?.cast<String>() ??
          [], // Changed from 'image' to 'images'
      isVisible: json['isVisible'] ?? true,
      isTakeout: json['isTakeout'] ?? false,
      options: (json['options'] as List<dynamic>?)
              ?.map((option) =>
                  MenuItemOption.fromJson(option as Map<String, dynamic>))
              .toList() ??
          [],
      discountAmount: json['discountAmount'] as int?,
      rewardPoints: json['rewardPoints'] as int?,
      // 주석: selectedOptions 파싱 로직 수정
      selectedOptions: (json['selectedOptions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              value is List ? List<String>.from(value) : [value.toString()],
            ),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'detailedDescription': detailedDescription,
      'price': price,
      'images': images,
      'isVisible': isVisible,
      'isTakeout': isTakeout,
      'options': options.map((option) => option.toJson()).toList(), // 추가된 옵션 목록
      'discountAmount': discountAmount, // 추가
      'rewardPoints': rewardPoints, // 추가
      'selectedOptions': selectedOptions,
    };
  }
}

class MenuCategory {
  final String name;
  final List<MenuItem> items;

  MenuCategory({
    required this.name,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      name: json['name'] ?? 'Unknown Category',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  MenuCategory copyWith({
    String? name,
    List<MenuItem>? items,
  }) {
    return MenuCategory(
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }
}

class Menu {
  final String restaurantId;
  List<MenuCategory> categories; // 'final' keyword removed

  Menu({
    required this.restaurantId,
    required this.categories,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      restaurantId: json['restaurantId'] ?? 'Unknown Restaurant',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) =>
                  MenuCategory.fromJson(category as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }

  Menu copyWith({
    String? restaurantId,
    List<MenuCategory>? categories,
  }) {
    return Menu(
      restaurantId: restaurantId ?? this.restaurantId,
      categories: categories ?? this.categories,
    );
  }
}
