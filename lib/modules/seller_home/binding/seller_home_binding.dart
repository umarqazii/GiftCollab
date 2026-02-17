import 'package:get/get.dart';
import '../controller/seller_home_controller.dart';

class SellerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerHomeController>(() => SellerHomeController());

    // Get.lazyPut<MyEventsController>(() => MyEventsController());
    // Get.lazyPut<JoinedEventsController>(() => JoinedEventsController());
    // Get.lazyPut<InvitedEventsController>(() => InvitedEventsController());
  }
}
