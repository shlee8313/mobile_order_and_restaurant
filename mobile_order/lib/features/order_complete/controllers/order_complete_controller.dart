// lib/features/order_complete/controllers/order_complete_controller.dart
import 'package:get/get.dart';
// import '../../../services/restaurant_service.dart';

class OrderCompleteController extends GetxController {
  final businessName = ''.obs;
  final orderNumber = ''.obs;
  final orderDetails = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    businessName.value = args['businessName'] ?? ''; // businessName으로 수정
    orderNumber.value = args['orderNumber']?.toString() ?? '';
    orderDetails.value = args['orderDetails'] ?? '';

    print('OrderComplete Arguments: $args'); // 데이터 확인용 로그
  }
}
