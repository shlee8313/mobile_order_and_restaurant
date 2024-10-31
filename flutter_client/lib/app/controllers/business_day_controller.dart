//file: \flutter_client\lib\app\controllers\business_day_controller.dart

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Dio 패키지 import 추가
import '../data/providers/api_provider.dart';
import '../controllers/sales_controller.dart';
import '../controllers/auth_controller.dart';
import '../data/models/business_day.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/**
 * 
 */
class BusinessDayController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  // final SalesController _salesController = Get.find<SalesController>();
  // final AuthController _authController = Get.find<AuthController>();

  Rx<String?> currentBusinessDayId = Rx<String?>(null);
  RxBool isBusinessDayActive = false.obs;
  RxString statusMessage = ''.obs;
  RxBool isFirstBusinessDay = false.obs;
// RxBool isBusinessDayActive = false.obs;
  Rx<DateTime?> businessDayStart = Rx<DateTime?>(null);

  // String? get _restaurantId => _authController.restaurant.value?.restaurantId;
  bool _isTimeZoneInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initializeTimeZone();
  }

  // 추가: 타임존 초기화 메서드
  void _initializeTimeZone() {
    if (!_isTimeZoneInitialized) {
      tz.initializeTimeZones();
      _isTimeZoneInitialized = true;
    }
  }

  Future<BusinessDay?> checkAndStartBusinessDay(String restaurantId) async {
    try {
      final response =
          await _apiProvider.post('/api/business-day/check-and-start', {
        'restaurantId': restaurantId,
      });

      print('Server response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String;
        final businessDayData = data['businessDay'] as Map<String, dynamic>?;
        final message = data['message'] as String;
        if (status == 'no_business_day') {
          print(
              'No active business day found. Starting a new one automatically.');
          return await startNewBusinessDay(restaurantId);
        }
        if (businessDayData != null) {
          final businessDay = BusinessDay.fromJson(businessDayData);
          print('Raw JSON for BusinessDay: $businessDayData');
          print('Business day parsed: $businessDay');

          currentBusinessDayId.value = businessDay.id;
          businessDayStart.value = businessDay.startTime;

          switch (status) {
            case 'active_business_day':
              isBusinessDayActive.value = true;
              break;
            case 'inactive_business_day':
              isBusinessDayActive.value = false;
              break;
            // case 'no_business_day':
            //   isBusinessDayActive.value = false;
            //   break;
            default:
              print('Unknown business day status: $status');
              throw Exception('Unknown business day status');
          }

          Get.snackbar(
            '알림',
            message,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );

          return businessDay;
        } else {
          print('BusinessDay data is null');
          isBusinessDayActive.value = false;
          Get.snackbar(
            '알림',
            message,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );
          return null;
        }
      } else {
        throw Exception(
            'Failed to check business day status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in checkAndStartBusinessDay: $e');
      Get.snackbar(
        '에러',
        '영업일 상태 확인 실패. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<BusinessDay?> startNewBusinessDay(String restaurantId) async {
    try {
      final response = await _apiProvider.post('/api/business-day/start', {
        'restaurantId': restaurantId,
      });

      if (response.statusCode == 200 && response.data != null) {
        final businessDayData =
            response.data['businessDay'] as Map<String, dynamic>?;
        final data = response.data;
        if (businessDayData != null) {
          final businessDay = BusinessDay.fromJson(businessDayData);
          currentBusinessDayId.value = businessDay.id;
          isBusinessDayActive.value = true;
          if (data['message'] != null) {
            Get.snackbar(
              '알림',
              data['message'],
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 3),
              backgroundColor: Colors.black87,
              colorText: Colors.white,
            );
            // Get.snackbar('알림', data['message']);
          }
          return businessDay;
        }
      }
      throw Exception('새 영업일을 시작하는데 실패했습니다.');
    } catch (e) {
      print('Error in startNewBusinessDay: $e');
      // Get.snackbar('에러', '새 영업일 시작 실패. 다시 시도해주세요.');
      Get.snackbar(
        '에러',
        '새 영업일 시작 실패. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> endBusinessDay(String? restaurantId) async {
    if (restaurantId == null) {
      // Get.snackbar('에러', '레스토랑 ID가 없습니다.');
      Get.snackbar(
        '에러',
        '레스토랑 ID가 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await _apiProvider.post('/api/business-day/end', {
        'restaurantId': restaurantId,
      });

      if (response.statusCode == 200) {
        isBusinessDayActive.value = false;
        currentBusinessDayId.value = null;
        businessDayStart.value = null;
        // Get.snackbar('알림', '영업이 마감되었습니다.');
        Get.snackbar(
          '알림',
          '영업이 마감되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to end business day: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        '에러',
        '영업 종료 실패. 다시 시도해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Get.snackbar('에러', '영업 종료 실패. 다시 시도해주세요.');
      rethrow;
    }
  }

  Future<void> cancelEndBusinessDay(String? restaurantId) async {
    if (restaurantId == null) {
      Get.snackbar('에러', '레스토랑 ID가 없습니다.');
      return;
    }

    try {
      final response = await _apiProvider.post('/api/business-day/cancel-end', {
        'restaurantId': restaurantId,
      });

      print('Server response for cancel-end: ${response.data}'); // 디버깅용 로그

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw Exception('서버 응답이 null입니다.');
        }

        if (response.data is! Map<String, dynamic>) {
          throw Exception('서버 응답이 예상과 다른 형식입니다: ${response.data.runtimeType}');
        }

        final data = response.data as Map<String, dynamic>;

        if (!data.containsKey('businessDay')) {
          throw Exception('서버 응답에 businessDay 정보가 없습니다.');
        }

        final businessDayData = data['businessDay'] as Map<String, dynamic>;
        final businessDay = BusinessDay.fromJson(businessDayData);

        isBusinessDayActive.value = true;
        currentBusinessDayId.value = businessDay.id;
        businessDayStart.value = businessDay.startTime;

        final message = data['message'] as String? ?? '영업이 재개되었습니다.';
        // Get.snackbar('알림', message);
        Get.snackbar(
          '알림',
          message,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      } else {
        throw Exception('영업 재개 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in cancelEndBusinessDay: $e');
      Get.snackbar('에러', '영업 재개 실패. 다시 시도해주세요. 오류: ${e.toString()}');
    }
  }

// 활성화된 영업일 확인 메서드
  // Future<bool> checkActiveBusinessDay() async {
  //   try {
  //     final restaurantId = _authController.restaurant.value?.restaurantId;
  //     if (restaurantId == null) {
  //       throw Exception('Restaurant ID is null');
  //     }

  //     final response = await _apiProvider
  //         .get('/api/business-day/status?restaurantId=$restaurantId');

  //     if (response.statusCode == 200) {
  //       final isBusinessDayActive = response.data['isActive'] ?? false;
  //       isBusinessDayActive.value = isBusinessDayActive;
  //       currentBusinessDayId.value =
  //           isBusinessDayActive ? response.data['businessDayId'] : null;
  //       return isBusinessDayActive;
  //     } else {
  //       throw Exception('영업일 상태 확인 실패: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Failed to check active business day: $e');
  //     return false;
  //   }
  // }
}
