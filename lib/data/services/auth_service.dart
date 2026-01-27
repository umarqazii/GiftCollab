import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthService> init() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
           Get.offAllNamed(Routes().getHomeScreen());
        });
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
           Get.offAllNamed(Routes().getLoginScreen());
        });
      }
    });
    return this;
  }
}