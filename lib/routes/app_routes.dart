import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gift_collab/modules/gift_registry/screen/gift_registry_screen.dart';
import 'package:gift_collab/modules/event_home/binding/event_home_binding.dart';
import 'package:gift_collab/modules/event_home/screen/event_home_screen.dart';
import 'package:gift_collab/modules/login/binding/login_binding.dart';
import 'package:gift_collab/modules/login/screen/login_screen.dart';
import 'package:gift_collab/modules/role_selection/binding/role_selection_binding.dart';
import 'package:gift_collab/modules/role_selection/screen/role_selection_screen.dart';
import 'package:gift_collab/modules/create_shop/binding/create_shop_binding.dart';
import 'package:gift_collab/modules/create_shop/screen/create_shop_screen.dart';
import 'package:gift_collab/modules/seller_home/binding/seller_home_binding.dart';
import 'package:gift_collab/modules/seller_home/screen/seller_home_screen.dart';
import 'package:gift_collab/modules/shop_products/binding/shop_products_binding.dart';
import 'package:gift_collab/modules/shop_products/screen/shop_products_screen.dart';
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
  String getEventHomeScreen() => EventHomeScreen.id;
  String getGiftRegistryScreen() => GiftRegistryScreen.id;
  String getRoleSelectionScreen() => RoleSelectionScreen.id;
  String getSplashScreen() => SplashScreen.id;
  String getSellerHomeScreen() => SellerHomeScreen.id;
  String getCreateShopScreen() => CreateShopScreen.id;
  String getShopProductsScreen() => ShopProductsScreen.id;

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
      name: EventHomeScreen.id,
      binding: EventHomeBinding(),
      page: () => const EventHomeScreen(),
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
    GetPage(
      name: SellerHomeScreen.id,
      binding: SellerHomeBinding(),
      page: () => SellerHomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: CreateShopScreen.id,
      binding: CreateShopBinding(),
      page: () => const CreateShopScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: ShopProductsScreen.id,
      binding: ShopProductsBinding(),
      page: () => const ShopProductsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
