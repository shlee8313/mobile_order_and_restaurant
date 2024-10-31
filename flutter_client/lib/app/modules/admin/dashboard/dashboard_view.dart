// file: lib/app/modules/admin/admin/admin_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends GetView {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Admin Dashboard'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: () {
      //         // TODO: Implement logout logic
      //         Get.offAllNamed('/login');
      //       },
      //     ),
      //   ],
      // ),
      body: Center(
        child: Text(
          'Welcome to the Admin Dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
