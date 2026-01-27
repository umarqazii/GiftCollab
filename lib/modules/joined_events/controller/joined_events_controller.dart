import 'package:get/get.dart';
import '../../../data/models/event_model.dart';
import '../repository/joined_events_repository.dart';

class JoinedEventsController extends GetxController{
  final JoinedEventsRepository _repository = JoinedEventsRepository();

  var joinedEvents = <EventModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    setupListener();
  }

  void setupListener() {
    isLoading.value = true;
    joinedEvents.bindStream(_repository.getJoinedEventsStream());
    ever(joinedEvents, (_) {
      isLoading.value = false;
    });
  }
}