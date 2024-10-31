// lib/features/qr_scanner/views/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_scanner_controller.dart';

class QrScannerPage extends GetView<QrScannerController> {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 페이지가 빌드될 때마다 스캐너 초기화

    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 스캐너')),
      body: Obx(() {
        if (!controller.hasPermission.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('카메라 권한이 필요합니다.'),
                ElevatedButton(
                  onPressed: controller.checkPermissionAndInitialize,
                  child: const Text('권한 요청'),
                ),
              ],
            ),
          );
        }

        if (!controller.isInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: MobileScanner(
                controller: controller.scannerController,
                onDetect: controller.onDetect,
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Text('카메라 오류: $error'),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'QR 코드를 스캔하세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      }),
    );
  }
}
