import 'package:get/get.dart';
import 'package:gift_collab/core/network/api_client.dart';
import '../controller/login_controller.dart';
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}