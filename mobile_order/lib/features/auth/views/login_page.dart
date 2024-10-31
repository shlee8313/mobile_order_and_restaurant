import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building LoginPage');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 80),
                  SignInButtonBuilder(
                    text: 'Sign in with Google',
                    icon: Icons.android,
                    onPressed: () async {
                      print('Google Sign In button pressed');
                      await controller.signInWithGoogle();
                    },
                    backgroundColor: Colors.grey[600]!,
                    width: 300.0,
                    height: 50.0,
                    fontSize: 20.0,
                    padding: EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  SignInButtonBuilder(
                    text: 'Sign in with Apple',
                    icon: Icons.apple,
                    onPressed: () async {
                      print('Apple Sign In button pressed');
                      await controller.signInWithApple();
                    },
                    backgroundColor: Colors.grey[600]!,
                    width: 300.0,
                    height: 50.0,
                    fontSize: 20.0,
                    padding: EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
