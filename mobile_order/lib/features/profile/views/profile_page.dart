//file \lib\features\profile\views\profile_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Page'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authController.signOut();
                // Optionally clear other stored data if necessary
                // Example: await clearLocalData();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
