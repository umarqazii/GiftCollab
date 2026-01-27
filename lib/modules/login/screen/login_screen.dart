import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_assets.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/widgets/custom_button.dart';
import '../controller/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  static const String id = '/login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const CircularProgressIndicator();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      AppAssets.appIcon,
                      fit: BoxFit.contain,
                    ), 
                    
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Simple. Smart. Fun.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Google Sign In Button
                  CustomButton(text: "Continue with Google", onPressed: controller.signInWithGoogle, leadingIcon: Icons.login,)
                  
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}