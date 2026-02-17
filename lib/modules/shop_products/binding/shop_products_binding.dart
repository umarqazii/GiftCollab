import 'package:get/get.dart';
import 'package:gift_collab/modules/shop_products/controller/shop_products_controller.dart';

class ShopProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopProductsController>(() => ShopProductsController());
  }
}
