import 'package:get/get.dart';
import 'package:gift_collab/modules/create_shop/controller/create_shop_controller.dart';

class CreateShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateShopController>(() => CreateShopController());
  }
}
