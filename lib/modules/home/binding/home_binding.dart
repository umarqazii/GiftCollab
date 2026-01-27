import 'package:get/get.dart';
import 'package:gift_collab/modules/home/controller/home_controller.dart';
import 'package:gift_collab/modules/invited_events/controller/invited_events_controller.dart';
import 'package:gift_collab/modules/joined_events/controller/joined_events_controller.dart';
import 'package:gift_collab/modules/my_events/controller/my_events_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    Get.lazyPut<MyEventsController>(() => MyEventsController());
    Get.lazyPut<JoinedEventsController>(() => JoinedEventsController());
    Get.lazyPut<InvitedEventsController>(() => InvitedEventsController());
  }
}