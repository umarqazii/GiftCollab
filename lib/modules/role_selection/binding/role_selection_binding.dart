import 'package:get/get.dart';
import 'package:gift_collab/modules/role_selection/controller/role_selection_controller.dart';

class RoleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleSelectionController>(() => RoleSelectionController());
  }
}