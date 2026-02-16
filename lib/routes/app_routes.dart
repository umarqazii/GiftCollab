import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gift_collab/modules/gift_registry/screen/gift_registry_screen.dart';
import 'package:gift_collab/modules/home/binding/home_binding.dart';
import 'package:gift_collab/modules/home/screen/home_screen.dart';
import 'package:gift_collab/modules/login/binding/login_binding.dart';
import 'package:gift_collab/modules/login/screen/login_screen.dart';
import 'package:gift_collab/modules/role_selection/binding/role_selection_binding.dart';
import 'package:gift_collab/modules/role_selection/screen/role_selection_screen.dart';
import 'package:gift_collab/modules/splash/binding/splash_binding.dart';
import 'package:gift_collab/modules/splash/screen/splash_screen.dart';


class Routes {
  static final Routes _sharedInstance = Routes._internal();

  factory Routes() {
    return _sharedInstance;
  }

  Routes._internal();

  //Define Routes Below
  String getLoginScreen() => LoginScreen.id;
  String getHomeScreen() => HomeScreen.id;
  String getGiftRegistryScreen() => GiftRegistryScreen.id;
  String getRoleSelectionScreen() => RoleSelectionScreen.id;
  String getSplashScreen() => SplashScreen.id;

  List<GetPage> routeMap = [
    GetPage(
      name: SplashScreen.id,
      binding: SplashBinding(),
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: LoginScreen.id,
      binding: LoginBinding(),
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: HomeScreen.id,
      binding: HomeBinding(),
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: GiftRegistryScreen.id,
      page: () => GiftRegistryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RoleSelectionScreen.id,
      binding: RoleSelectionBinding(),
      page: () => RoleSelectionScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
