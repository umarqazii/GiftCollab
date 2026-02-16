import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_assets.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/modules/splash/controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  static const String id = '/splash';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: Image.asset(
                  AppAssets.appIcon,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Gift Collab',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Simple. Smart. Fun.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
