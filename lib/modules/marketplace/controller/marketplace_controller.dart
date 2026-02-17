import 'package:get/get.dart';
import 'package:gift_collab/data/models/user_model.dart';
import 'package:gift_collab/data/repositories/user_repository.dart';
import 'package:gift_collab/routes/app_routes.dart';

class MarketplaceController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  var shops = <UserModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    shops.bindStream(_userRepository.getShopsStream());
    ever(shops, (_) => isLoading.value = false);
  }

  void openShop(UserModel shop) {
    Get.toNamed(
      Routes().getShopProductsScreen(),
      arguments: {
        'sellerId': shop.uid,
        'shopName': shop.shopName,
        'shopDisplayPicUrl': shop.shopDisplayPicUrl,
        'shopCategory': shop.shopCategory,
      },
    );
  }
}
