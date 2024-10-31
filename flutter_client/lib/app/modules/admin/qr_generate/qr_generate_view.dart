// file: lib/app/modules/admin/qr/qr_view.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/table_controller.dart';
import '../../../../core/utils/encryption_helper.dart';

class QrGenerateView extends GetView<AuthController> {
  final EncryptionHelper _encryptionHelper = EncryptionHelper();

  String prepareData(String restaurantId, {String? tableId}) {
// 출력: restaurantId와 tableId의 값을 확인
    print('restaurantId: $restaurantId');
    if (tableId != null) {
      print('tableId: $tableId');
    } else {
      print('tableId is null');
    }

    final data = tableId != null
        ? 'RESTAURANT:$restaurantId;TABLE:$tableId'
        : 'RESTAURANT:$restaurantId';
    print('Prepared data: $data');
    return data;
  }

  Future<String?> getDownloadPath() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile-specific storage path
        Directory? directory = await getExternalStorageDirectory();
        return directory?.path;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        Directory? directory = await getDownloadsDirectory();
        return directory?.path;
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } catch (e) {
      print('Error getting download path: $e');
      return null;
    }
  }

  Future<void> downloadQr(
      BuildContext context, GlobalKey key, String label) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장소 접근 권한이 필요합니다')),
        );
        return;
      }
    }

    final downloadPath = await getDownloadPath();
    if (downloadPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다운로드 경로를 찾을 수 없습니다.')),
      );
      return;
    }

    final imagePath =
        '$downloadPath${Platform.pathSeparator}${label.replaceAll(' ', '_')}.png';

    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final file = File(imagePath);
        await file.writeAsBytes(pngBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR 코드가 다운로드되었습니다: $imagePath')),
        );
      } else {
        throw Exception('이미지 데이터를 가져올 수 없습니다.');
      }
    } catch (e) {
      print('Error during QR download: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다운로드 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Widget buildQrCode(BuildContext context, String restaurantId,
      {String? tableId, required String label, double? size}) {
    final screenSize = MediaQuery.of(context).size;
    final defaultSize = screenSize.width * 0.15;
    final qrSize = size ?? defaultSize;

    final preparedData = prepareData(restaurantId, tableId: tableId);
    print('Prepared Data for QR Code: $preparedData');

    final encryptedData = _encryptionHelper.encryptData(preparedData);

    final GlobalKey qrKey = GlobalKey();
    return RepaintBoundary(
      key: qrKey,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: QrImageView(
                data: encryptedData,
                version: QrVersions.auto,
                size: qrSize,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(qrSize * 0.4, qrSize * 0.4),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.download, size: 20),
                onPressed: () => downloadQr(context, qrKey, label),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final qrSizeSingle = screenSize.width * 0.2;
    final qrSizeMultiple = screenSize.width * 0.15;

    return Scaffold(
      body: Obx(() {
        final restaurant = controller.restaurant.value;
        if (restaurant == null) {
          return Center(child: Text('레스토랑 정보를 불러올 수 없습니다.'));
        }

        if (!restaurant.hasTables) {
          return Center(
            child: buildQrCode(
              context,
              restaurant.restaurantId, // restaurantId
              label: '${restaurant.businessName} QR 코드', // 레이블
              size: qrSizeSingle,
            ),
          );
        } else {
          final tableController = Get.find<TableController>();
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: tableController.tables.length,
            itemBuilder: (context, index) {
              final table = tableController.tables[index];
              return buildQrCode(
                context,
                restaurant.restaurantId, // restaurantId
                tableId: table.tableId.toString(), // int를 String으로 변환
                label: '테이블 ${table.tableId}', // 레이블
                size: qrSizeMultiple,
              );
            },
          );
        }
      }),
    );
  }
}
