import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gift_collab/modules/home/binding/home_binding.dart';
import 'package:gift_collab/modules/home/screen/home_screen.dart';
import 'package:gift_collab/modules/login/binding/login_binding.dart';
import 'package:gift_collab/modules/login/screen/login_screen.dart';


class Routes {
  static final Routes _sharedInstance = Routes._internal();

  factory Routes() {
    return _sharedInstance;
  }

  Routes._internal();

  //Define Routes Below
  String getLoginScreen() => LoginScreen.id;
  String getHomeScreen() => HomeScreen.id;
  
  List<GetPage> routeMap = [
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
    
    
  ];
}
