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
    
    // bindStream automatically updates 'myEvents' whenever Firestore changes
    myEvents.bindStream(_repository.getMyEventsStream());
    
    // Determine when to stop loading. 
    // Since streams are continuous, we can create a worker that 
    // turns off loading as soon as the first batch of data arrives.
    ever(myEvents, (_) {
      isLoading.value = false;
    });
  }

}