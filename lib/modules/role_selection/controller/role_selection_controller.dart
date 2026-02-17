import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_roles.dart';
import 'package:gift_collab/data/repositories/user_repository.dart';
import 'package:gift_collab/data/services/storage_service.dart';
import 'package:gift_collab/routes/app_routes.dart';

class RoleSelectionController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final UserRepository _userRepository = UserRepository();

  /// Whether the user chose Event Management.
  bool get isEventManagement =>
      AppRoles.isEventManagement(_storage.getRole());

  /// Whether the user chose Seller Management.
  bool get isSellerManagement =>
      AppRoles.isSellerManagement(_storage.getRole());

  Future<void> selectEventManagement() async {
    await _storage.saveRole(AppRoles.eventManagement);
    Get.offAllNamed(Routes().getEventHomeScreen());
  }

  Future<void> selectSellerManagement() async {
    await _storage.saveRole(AppRoles.sellerManagement);
    final user = await _userRepository.getCurrentUser();
    if (user == null || !user.hasShop) {
      Get.offAllNamed(Routes().getCreateShopScreen());
    } else {
      Get.offAllNamed(Routes().getSellerHomeScreen());
    }
  }
}
