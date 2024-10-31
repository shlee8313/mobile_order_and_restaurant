//file: \flutter_client\lib\app\middleware\auth_middleware.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If the user is not authenticated and trying to access a protected route
    if (!authController.isAuthenticated && route != Routes.LOGIN) {
      return RouteSettings(name: Routes.LOGIN);
    }

    // If the user is authenticated and trying to access login page, redirect to admin
    if (authController.isAuthenticated && route == Routes.LOGIN) {
      return RouteSettings(name: Routes.ADMIN);
    }

    return null;
  }
}
