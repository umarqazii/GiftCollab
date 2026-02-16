import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    // Start the check as soon as the screen is visible
    _startApp();
  }

  Future<void> _startApp() async {
    // 1. Wait for your Splash Animation (e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Check "Am I logged in?" directly from Firebase
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // LOGGED IN: Go to Role Selection (or Home)
      // verify that this route string is correct in your AppRoutes file!
      Get.offAllNamed(Routes().getRoleSelectionScreen());
    } else {
      // LOGGED OUT: Go to Login
      Get.offAllNamed(Routes().getLoginScreen());
    }
  }
}