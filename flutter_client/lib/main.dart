//file: \flutter_client\lib\main.dart

import 'package:flutter/material.dart';
// import 'package:flutter_client/app/controllers/menu_edit_controller.dart';
// import 'package:flutter_client/app/modules/admin/admin_order/admin_order_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv import 추가
// import 'app/data/services/socket_service.dart';
import 'package:flutter/services.dart'; // SystemChrome을 위한 import 추가
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'app/routes/app_pages.dart';
import 'app/ui/theme/app_theme.dart';
import 'app/data/providers/api_provider.dart';
// import 'app/controllers/auth_controller.dart';
// import 'app/controllers/navigation_controller.dart';
// import 'app/controllers/sales_controller.dart';
// import 'app/controllers/order_controller.dart';
// import 'app/data/providers/order_api.dart';
// import 'app/controllers/table_controller.dart'; // 추가: TableController import
// import 'app/controllers/order_queue_controller.dart'; // 추가: OrderQueueController import
// import 'app/controllers/quick_order_controller.dart';
// import 'app/controllers/home_controller.dart';
// import 'app/controllers/menu_edit_controller.dart';
import 'app/controllers/controller_provider.dart';
// import 'app/data/services/socket_service.dart'; // 추가
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app/data/services/audio_service.dart';
/**
 * 
 */

import 'package:flutter/material.dart';
// ... 기존 imports 유지

Future<void> initWindow() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
      title: "딩동 주문",
      // size: Size(1024, 768),
      // minimumSize: Size(1024, 768), // 최소 크기도 더 크게 설정
      alwaysOnTop: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.maximize();
      // await windowManager.setResizable(false);
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initServices();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  await initWindow();

  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
      // _initializeWindow();
    }
  }

  // Future<void> _initializeWindow() async {
  //   // 시작할 때 바로 최대화
  //   await windowManager.maximize();
  // }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  // @override
  // void onWindowResize() async {
  //   super.onWindowResize();
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await windowManager.maximize();
  // }

  // @override
  // void onWindowMinimize() async {
  //   super.onWindowMinimize();
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await windowManager.maximize();
  // }

  // @override
  // void onWindowMaximize() async {
  //   super.onWindowMaximize();
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await windowManager.setResizable(false);
  // }

  // @override
  // void onWindowUnmaximize() async {
  //   super.onWindowUnmaximize();
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await windowManager.maximize();
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "딩동 주문",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialBinding: ControllerBinding(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
    );
  }
}

Future<void> initServices() async {
  print('starting services ...');
  await Get.putAsync(() => ApiProvider().init());
  await Get.putAsync(() => AudioService().init());
}
