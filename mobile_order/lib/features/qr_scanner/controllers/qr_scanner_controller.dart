// lib/features/qr_scanner/controllers/qr_scanner_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/encryption_helper.dart';
import '../../restaurant_menu/views/restaurant_menu_page.dart';
import '../../restaurant_menu/bindings/restaurant_menu_binding.dart';
// import '../../restaurant_menu/controllers/restaurant_menu_controller.dart';

class QrScannerController extends GetxController {
  final EncryptionHelper _encryptionHelper;
  late MobileScannerController scannerController;
  RxBool isScanning = true.obs;
  RxBool isInitialized = false.obs;
  RxBool hasPermission = false.obs;
  QrScannerController(this._encryptionHelper);

  @override
  void onInit() {
    super.onInit();
    checkPermissionAndInitialize();
  }

  Future<void> checkPermissionAndInitialize() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      hasPermission.value = true;
      await initializeScanner();
    } else {
      hasPermission.value = false;
      _showSnackBar('권한 오류', '카메라 권한이 필요합니다.', isError: true);
    }
  }

  Future<void> initializeScanner() async {
    scannerController = MobileScannerController();
    try {
      await scannerController.start();
      isInitialized.value = true;
    } catch (e) {
      print('Error initializing scanner: $e');
      _showSnackBar('오류', '카메라를 초기화할 수 없습니다.', isError: true);
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void resetScanner() async {
    isInitialized.value = false;
    await scannerController.stop();
    scannerController.dispose();
    await initializeScanner();
  }

  void onDetect(BarcodeCapture capture) {
    if (!isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null) {
        processQrCode(rawValue);
        break; // Process only the first detected QR code
      }
    }
  }

  void processQrCode(String rawValue) {
    try {
      print('Raw scanned value: $rawValue');
      final decryptedData = _encryptionHelper.decryptData(rawValue);

      if (decryptedData.isEmpty) {
        print('Decryption failed or resulted in empty string');
        _showSnackBar('오류', 'QR 코드를 해독할 수 없습니다.', isError: true);
        return;
      }

      print('Decrypted data: $decryptedData');
      final parts = decryptedData.split(';');

      Map<String, String> parsedData = {};
      for (var part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          parsedData[keyValue[0]] = keyValue[1];
        }
      }

      print('Parsed data: $parsedData');

      final restaurantId = parsedData['RESTAURANT'];
      final tableId = parsedData['TABLE'];

      if (restaurantId != null) {
        _pauseScanning();
        // Navigate to RestaurantMenuPage as a new screen
        Get.off(
          () => RestaurantMenuPage(),
          binding: RestaurantMenuBinding(),
          arguments: {'restaurantId': restaurantId, 'tableId': tableId},
        );
      } else {
        print('No RESTAURANT key found in parsed data');
        _showSnackBar('오류', 'QR 코드에 레스토랑 정보가 없습니다.', isError: true);
      }
    } catch (e) {
      print('QR 스캔 오류: $e');
      _showSnackBar('오류', 'QR 코드를 처리할 수 없습니다: $e', isError: true);
    }
  }

  void _showSnackBar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red.shade300 : Colors.green.shade300,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  void _pauseScanning() {
    isScanning.value = false;
    scannerController.stop();
    Future.delayed(const Duration(seconds: 3), () {
      isScanning.value = true;
      scannerController.start();
    });
  }
}
