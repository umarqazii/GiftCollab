import 'package:get/get.dart';
import '../../../data/models/event_model.dart';
import '../repository/invited_events_repository.dart';

class InvitedEventsController extends GetxController {
  final InvitedEventsRepository _repository = InvitedEventsRepository();

  var invitedEvents = <EventModel>[].obs;
  var isLoading = true.obs;
  var isProcessingAction = false.obs;

  @override
  void onInit() {
    super.onInit();
    setupListener();
  }

  void setupListener() {
    isLoading.value = true;
    invitedEvents.bindStream(_repository.getInvitedEventsStream());
    ever(invitedEvents, (_) {
      isLoading.value = false;
    });
  }

  Future<void> acceptInvite(String eventId) async {
    try {
      isProcessingAction.value = true;
      await _repository.acceptInvitation(eventId);
      Get.snackbar("Success", "You have joined the event!");
      // The event will automatically disappear from this list (via stream) 
      // and appear in the "Joined" tab.
    } catch (e) {
      Get.snackbar("Error", "Could not accept invitation");
    } finally {
      isProcessingAction.value = false;
    }
  }

  Future<void> declineInvite(String eventId) async {
    try {
      isProcessingAction.value = true;
      await _repository.declineInvitation(eventId);
      Get.snackbar("Declined", "Invitation removed.");
    } catch (e) {
      Get.snackbar("Error", "Could not decline invitation");
    } finally {
      isProcessingAction.value = false;
    }
  }
}