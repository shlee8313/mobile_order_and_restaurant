// file: lib/app/modules/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              child: Text('Go to Login'),
              onPressed: () => Get.toNamed('/login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Go to Register'),
              onPressed: () => Get.toNamed('/register'),
            ),
          ]),
        ));
  }
}
