import 'package:get/get.dart';
import 'package:gift_collab/data/models/product_model.dart';
import 'package:gift_collab/modules/seller_products/repository/seller_product_repository.dart';

class ShopProductsController extends GetxController {
  final SellerProductRepository _repository = SellerProductRepository();

  late String sellerId;
  late String shopName;
  String shopDisplayPicUrl = '';
  String shopCategory = '';

  var products = <ProductModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      isLoading.value = false;
      return;
    }
    sellerId = args['sellerId'] as String? ?? '';
    shopName = args['shopName'] as String? ?? 'Shop';
    shopDisplayPicUrl = args['shopDisplayPicUrl'] as String? ?? '';
    shopCategory = args['shopCategory'] as String? ?? '';

    if (sellerId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    products.bindStream(_repository.getProductsBySellerStream(sellerId));
    ever(products, (_) => isLoading.value = false);
  }
}
