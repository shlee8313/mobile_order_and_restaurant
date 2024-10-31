// file: lib/controllers/business_day_controller.dart

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import '../models/business_day.dart';
import '../core/config/api_config.dart';
import '../services/auth_service.dart'; // 토큰을 가져오기 위한 서비스

class BusinessDayController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  Rx<String?> currentBusinessDayId = Rx<String?>(null);
  RxBool isBusinessDayActive = false.obs;
  Rx<DateTime?> businessDayStart = Rx<DateTime?>(null);

  Future<void> checkBusinessDayStatus(String restaurantId) async {
    try {
      final token = await _authService.getUserToken(); // 토큰 가져오기

      // 토큰 출력해서 확인
      print("Retrieved Token: $token");

      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/business-day/status/customer?restaurantId=$restaurantId'), // 여기에서 ? 하나로 수정
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // 2. 응답 데이터 확인
        // print("Parsed data: $data");

        final isActive = data['isActive'] as bool;
        final businessDayId = data['businessDayId'] as String?;
        final startTime = data['startTime'] as String?;

        // 3. 각 필드 확인
        // print("isActive: $isActive");
        // print("businessDayId: $businessDayId");
        // print("startTime: $startTime");

        if (businessDayId != null && startTime != null) {
          currentBusinessDayId.value = businessDayId;
          businessDayStart.value = DateTime.parse(startTime);
          isBusinessDayActive.value = isActive;
        } else {
          currentBusinessDayId.value = null;
          businessDayStart.value = null;
          isBusinessDayActive.value = false;
        }

        // Get.snackbar(
        //   '알림',
        //   isBusinessDayActive.value ? '영업 중입니다.' : '영업 중이 아닙니다.',
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: Duration(seconds: 3),
        // );
      } else {
        throw Exception(
            'Failed to check business day status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in checkBusinessDayStatus: $e');
      Get.snackbar(
        '에러',
        '영업일 상태 확인 실패. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String getFormattedBusinessDayStart() {
    if (businessDayStart.value != null) {
      return "${businessDayStart.value!.year}-${businessDayStart.value!.month.toString().padLeft(2, '0')}-${businessDayStart.value!.day.toString().padLeft(2, '0')} ${businessDayStart.value!.hour.toString().padLeft(2, '0')}:${businessDayStart.value!.minute.toString().padLeft(2, '0')}";
    }
    return "영업일 정보 없음";
  }
}
