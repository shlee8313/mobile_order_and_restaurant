// lib/features/order_complete/views/order_complete_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_complete_controller.dart';
import '../../../navigation/controllers/navigation_controller.dart';

class OrderCompletePage extends GetView<OrderCompleteController> {
  const OrderCompletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("주문 완료"), // 앱바 타이틀은 '주문 완료'로 고정
        // centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            // NavigationController 상태도 함께 업데이트
            final navigationController = Get.find<NavigationController>();
            navigationController.resetNavigation(); // 네비게이션 상태 리셋
            Get.offAllNamed('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(() => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // 식당 이름 추가
                  Text(
                    controller.businessName.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // '주문완료' 텍스트
                  const Text(
                    '주문완료',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // 주문 번호
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '주문번호',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.orderNumber.value,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 주문 내용
                  const Text(
                    '주문 내용',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.orderDetails.value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 안내 메시지
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '주문하신 메뉴가 준비되면\n푸시 알림으로 알려드립니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )),
      ),
    );
  }
}
