import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/modules/event_home/controller/event_home_controller.dart';
import 'package:gift_collab/routes/app_routes.dart';
import 'package:gift_collab/modules/invited_events/screen/invited_events_screen.dart';
import 'package:gift_collab/modules/joined_events/screen/joined_events_screen.dart';
import 'package:gift_collab/modules/marketplace/screen/marketplace_screen.dart';
import 'package:gift_collab/modules/my_events/screen/my_events_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class EventHomeScreen extends GetView<EventHomeController> {
  static const String id = '/event_home';
  const EventHomeScreen({super.key});

  static final List<Widget> _widgetOptions = <Widget>[
    MyEventsScreen(),
    InvitedEventsScreen(),
    JoinedEventsScreen(),
    MarketplaceScreen(),
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
                  icon: Icons.event,
                  text: 'My Events',
                ),
                GButton(
                  icon: Icons.mail_outline,
                  text: 'Invitations',
                ),
                GButton(
                  icon: Icons.event_available,
                  text: 'Joined',
                ),
                GButton(
                  icon: Icons.storefront,
                  text: 'Marketplace',
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
