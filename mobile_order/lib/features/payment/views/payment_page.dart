// file: lib/features/payment/views/payment_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_controller.dart';
import '../../../core/widgets/custom_button.dart';
// import '../../restaurant_menu/views/restaurant_menu_page.dart';

class PaymentPage extends GetView<PaymentController> {
  final NumberFormat currencyFormat = NumberFormat('#,###', 'ko_KR');

  PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('결제'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back(result: false); // result: false로 수정
            },
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator()); // 로딩 인디케이터 표시
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '주문 내역',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildOrderList(),
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 결제 금액',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${currencyFormat.format(controller.totalAmount)}원',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: '결제하기',
                  onPressed: () async {
                    final result = await controller.processPayment();
                    if (result) {
                      Get.until((route) => route.isFirst); // 메인 화면으로 이동
                      // Get.snackbar(
                      //   '결제 성공',
                      //   '주문이 완료되었습니다.',
                      //   snackPosition: SnackPosition.BOTTOM,
                      //   duration: const Duration(seconds: 2),
                      // );
                    } else {
                      Get.snackbar('결제 실패', '결제 처리 중 오류가 발생했습니다.',
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: Colors.white,
                          backgroundColor: Colors.black);
                    }
                  },
                ),
              ],
            ),
          );
        }));
  }

  Widget _buildOrderList() {
    // 숫자를 안전하게 int로 변환하는 헬퍼 함수
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int calculateOptionsTotal(List<dynamic> selectedOptions) {
      int total = 0;
      for (var option in selectedOptions) {
        if (option.price != null) {
          total += safeParseInt(option.price);
        }
      }
      return total;
    }

    int calculateBasePrice(dynamic item) {
      // 주석: item.price에서 옵션 가격을 제외한 실제 기본 가격 계산
      final totalOptionPrice =
          calculateOptionsTotal(item.selectedOptions ?? []);
      return safeParseInt(item.price) - totalOptionPrice;
    }

    // int calculateItemTotal(dynamic item) {
    //   // 주석: item.price에 이미 옵션 가격이 포함되어 있으므로 quantity만 곱함
    //   final quantity = safeParseInt(item.quantity);
    //   return safeParseInt(item.price) * quantity;
    // }

    int calculateOptionsPriceWithQuantity(dynamic item) {
      if (item.selectedOptions == null || item.selectedOptions.isEmpty) {
        return 0;
      }
      // 주석: 옵션 가격만 따로 계산
      return calculateOptionsTotal(item.selectedOptions) *
          safeParseInt(item.quantity);
    }

    Widget buildListItem(dynamic item, int index, bool isQuickOrder) {
      // 주석: 가격 계산을 위한 변수들
      final basePrice = calculateBasePrice(item); // 주석: 순수 기본 가격 (옵션 제외)
      final quantity = safeParseInt(item.quantity);
      final itemTotal = safeParseInt(item.price) * quantity; // 주석: 총 가격 (옵션 포함)
      final optionsPrice = calculateOptionsPriceWithQuantity(item);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => controller.removeItem(index),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            elevation: 3.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(basePrice)}원', // 주석: 기본 가격 (옵션 제외)
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'x   $quantity',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${currencyFormat.format(itemTotal)}원', // 주석: 총 가격 표시
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (optionsPrice > 0) // 주석: 옵션 가격이 있을 경우만 표시
                            Text(
                              '(옵션: +${currencyFormat.format(optionsPrice)}원)', // 주석: 옵션 합계 (수량 반영)
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => controller.removeItem(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                      ),
                    ],
                  ),
                  if (item.selectedOptions != null &&
                      item.selectedOptions.isNotEmpty) ...[
                    const Divider(height: 8),
                    ...item.selectedOptions.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${option.name}: ${option.choice}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // 주석: 글자가 너무 길 경우 ...으로 표시
                                      maxLines: 1, // 주석: 한 줄로만 표시
                                    ),
                                  ),
                                  if (safeParseInt(option.price) > 0)
                                    SizedBox(width: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '+${currencyFormat.format(safeParseInt(option.price) * quantity)}원',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 주석: 리스트 반환부 추가
    if (controller.order != null) {
      return ListView.builder(
        itemCount: controller.order!.items.length,
        itemBuilder: (context, index) =>
            buildListItem(controller.order!.items[index], index, false),
      );
    }

    if (controller.quickOrder != null) {
      return ListView.builder(
        itemCount: controller.quickOrder!.items.length,
        itemBuilder: (context, index) =>
            buildListItem(controller.quickOrder!.items[index], index, true),
      );
    }

    return const Center(child: Text('주문 정보가 없습니다.'));
  }
}
