import 'package:get/get.dart';
import 'package:gift_collab/data/models/event_model.dart';
import 'package:gift_collab/modules/my_events/repository/my_events_repository.dart';

class MyEventsController extends GetxController {
  final MyEventsRepository _repository = MyEventsRepository();

  var myEvents = <EventModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    setupEventsListener();
  }

  void setupEventsListener() {
    isLoading.value = true;
    myEvents.bindStream(_repository.getMyEventsStream());
    ever(myEvents, (_) {
      isLoading.value = false;
    });
  }

}