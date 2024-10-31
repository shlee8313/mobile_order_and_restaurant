import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/menu.dart';
import '../controllers/restaurant_menu_controller.dart';
import 'item_detail_bottom_sheet.dart';
import 'cart_bottom_sheet.dart';
import 'package:intl/intl.dart'; // 주석: 가격 포맷팅을 위한 intl 패키지 추가

enum OptionMode {
  addToCart,
  orderNow,
}

class MenuOptionBottomSheet extends StatefulWidget {
  final MenuItem item;
  final OptionMode mode;

  const MenuOptionBottomSheet({
    Key? key,
    required this.item,
    required this.mode,
  }) : super(key: key);

  @override
  _MenuOptionBottomSheetState createState() => _MenuOptionBottomSheetState();
}

class _MenuOptionBottomSheetState extends State<MenuOptionBottomSheet> {
  final Map<String, List<String>> selectedOptions =
      {}; // 주석: String -> List<String>로 변경하여 다중 선택 지원
  // 주석: 각 옵션의 유효성 검사를 위한 맵 추가
  final Map<String, bool> optionValidation = {};
  final RestaurantMenuController controller =
      Get.find<RestaurantMenuController>();
  bool hasParentSheet = false;

  @override
  void initState() {
    super.initState();
    hasParentSheet = Get.previousRoute.contains('ItemDetailBottomSheet');

    // 주석: 초기화 로직 수정 - 기본 선택값 처리
    for (var option in widget.item.options) {
      selectedOptions[option.name] = [];
      if (option.defaultChoice != null) {
        selectedOptions[option.name]!.add(option.defaultChoice!);
      }
      // 주석: 초기 유효성 상태 설정
      optionValidation[option.name] = !option.isRequired ||
          (option.defaultChoice != null &&
              selectedOptions[option.name]!.isNotEmpty);
    }
  }

  bool _validateOptions() {
    for (var option in widget.item.options) {
      // 주석: 필수 옵션이고 선택되지 않은 경우
      if (option.isRequired) {
        final selectedChoices = selectedOptions[option.name];
        if (selectedChoices == null || selectedChoices.isEmpty) {
          Get.snackbar(
            '필수 옵션',
            '${option.name}은(는) 필수 선택 항목입니다.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            duration: const Duration(seconds: 2),
          );
          return false;
        }
      }

      // 주석: 다중 선택 옵션의 경우 최소/최대 선택 개수 검증 추가 가능
      // if (option.isMultiple) {
      //   final selectedCount = selectedOptions[option.name]?.length ?? 0;
      //   if (option.minSelection != null && selectedCount < option.minSelection!) {
      //     Get.snackbar(
      //       '옵션 선택',
      //       '${option.name}은(는) 최소 ${option.minSelection}개 선택해야 합니다.',
      //       snackPosition: SnackPosition.BOTTOM,
      //     );
      //     return false;
      //   }
      //   if (option.maxSelection != null && selectedCount > option.maxSelection!) {
      //     Get.snackbar(
      //       '옵션 선택',
      //       '${option.name}은(는) 최대 ${option.maxSelection}개까지 선택 가능합니다.',
      //       snackPosition: SnackPosition.BOTTOM,
      //     );
      //     return false;
      //   }
      // }
    }
    return true;
  }

  void _handleAddToCart() {
    if (!_validateOptions()) return; // 주석: 필수 옵션 검증 추가

    controller.addToCart(
      widget.item,
      selectedOptions,
      widget.mode,
    );

    Navigator.pop(context);
    if (hasParentSheet) {
      Navigator.pop(context);
    }
  }

  void _handleBack() async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ItemDetailBottomSheet(item: widget.item);
      },
    );
  }

  //  void _handleAddToCart() {
  //   if (!_validateOptions()) return; // 주석: 유효성 검사 추가

  //   controller.addToCart(
  //     widget.item,
  //     selectedOptions,
  //     widget.mode,
  //   );

  //   Navigator.pop(context);
  //   if (hasParentSheet) {
  //     Navigator.pop(context);
  //   }
  // }

  void _handleOrderNow() async {
    if (!_validateOptions()) return; // 주석: 유효성 검사 추가

    controller.addToCart(
      widget.item,
      selectedOptions,
      widget.mode,
    );

    Navigator.pop(context);
    final cartBottomSheet = CartBottomSheet();
    await cartBottomSheet.processOrder();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        _handleBack();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Positioned(
                          //   left: 0,
                          //   top: 8,
                          //   child: IconButton(
                          //     icon: const Icon(Icons.arrow_back),
                          //     onPressed: _handleBack,
                          //   ),
                          // ),
                          Column(
                            children: [
                              Container(
                                height: 5,
                                width: 40,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.item.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.item.options
                          .map((option) => _buildOptionWidget(option)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.mode == OptionMode.addToCart
                              ? _handleAddToCart
                              : _handleOrderNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.mode == OptionMode.addToCart
                                ? Colors.grey[600]
                                : Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // 중앙 정렬
                            children: [
                              Text(
                                widget.mode == OptionMode.addToCart
                                    ? '장바구니에 추가'
                                    : '바로 주문하기',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  // 선택된 옵션들의 총 가격 계산
                                  int totalOptionPrice = 0;
                                  selectedOptions
                                      .forEach((optionName, choices) {
                                    final option =
                                        widget.item.options.firstWhere(
                                      (opt) => opt.name == optionName,
                                      orElse: () =>
                                          MenuItemOption(name: '', choices: []),
                                    );

                                    for (final choiceName in choices) {
                                      final choice = option.choices.firstWhere(
                                        (ch) => ch.name == choiceName,
                                        orElse: () =>
                                            Choice(name: '', price: 0),
                                      );
                                      totalOptionPrice += choice.price;
                                    }
                                  });

                                  // 총 옵션 가격이 0보다 클 때만 표시
                                  return totalOptionPrice > 0
                                      ? Text(
                                          ' (+${NumberFormat('#,###').format(totalOptionPrice)}원)',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionWidget(MenuItemOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: Row(
            children: [
              Text(
                option.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              if (option.isRequired) // 주석: 필수 옵션 표시 추가
                Text(
                  '(필수)',
                  style: TextStyle(
                    color: Colors.red[500],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (option.isMultiple) // 주석: 다중 선택 가능 표시 추가
                Text(
                  '(중복 선택 가능)',
                  style: TextStyle(
                    color: Colors.blue[500],
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: option.choices
                .map((choice) => _buildCustomRadioTile(
                      choice: choice,
                      option: option,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRadioTile({
    required Choice choice,
    required MenuItemOption option,
  }) {
    final isSelected = selectedOptions[option.name]?.contains(choice.name) ??
        false; // 주석: 다중 선택 지원을 위한 contains 체크
    final formattedPrice = NumberFormat('#,###').format(choice.price);

    return InkWell(
      onTap: () {
        setState(() {
          if (option.isMultiple) {
            // 주석: 다중 선택 로직 추가
            selectedOptions[option.name] ??= [];
            if (isSelected) {
              selectedOptions[option.name]!.remove(choice.name);
            } else {
              selectedOptions[option.name]!.add(choice.name);
            }
          } else {
            // 주석: 단일 선택 로직
            selectedOptions[option.name] = [choice.name];
          }

          // 주석: 옵션 선택 상태 업데이트
          optionValidation[option.name] = !option.isRequired ||
              (selectedOptions[option.name]?.isNotEmpty ?? false);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                // 주석: 다중/단일 선택에 따른 모양 변경
                shape: option.isMultiple ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    option.isMultiple ? BorderRadius.circular(4) : null,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: option.isMultiple
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.blue)
                          : Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                choice.name,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (choice.price > 0)
              Text(
                "+${formattedPrice}원",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
