import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/modules/seller_dashboard/screen/seller_dashboard_screen.dart';
import 'package:gift_collab/routes/app_routes.dart';
import 'package:gift_collab/modules/seller_orders/screen/seller_order_screen.dart';
import 'package:gift_collab/modules/seller_products/screen/seller_product_screen.dart';
import 'package:gift_collab/modules/seller_profile/screen/seller_profile_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../controller/seller_home_controller.dart';

class SellerHomeScreen extends GetView<SellerHomeController> {
  static const String id = '/seller_home';
  const SellerHomeScreen({super.key});

  static final List<Widget> _widgetOptions = <Widget>[
    SellerProductScreen(),
    SellerDashboardScreen(),
    SellerOrderScreenScreen(),
    SellerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(Routes().getRoleSelectionScreen()),
          tooltip: 'Back to role selection',
        ),
        title: const Text('GiftCollab'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Yes",
                textCancel: "No",
                buttonColor: AppColors.primaryPurple,
                cancelTextColor: AppColors.primaryPurple,
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Obx(() => _widgetOptions.elementAt(controller.selectedTabIndex.value)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: AppColors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: AppColors.primaryPurple.withValues(alpha: 0.3),
              hoverColor: AppColors.grey,
              gap: 8,
              activeColor: AppColors.primaryPurple,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
              color: AppColors.grey,
              tabs: const [
                GButton(
                  icon: Icons.inventory,
                  text: 'My Products',
                ),
                GButton(
                  icon: Icons.insert_chart,
                  text: 'Dashboard',
                ),
                GButton(
                  icon: Icons.card_giftcard,
                  text: 'Orders',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
              ],
              selectedIndex: controller.selectedTabIndex.value,
              onTabChange: (index) {
                controller.changeTab(index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
