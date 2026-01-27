import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gift_collab/modules/my_events/controller/my_events_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxInt selectedTabIndex = 0.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> logout() async {
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        await _googleSignIn.signOut();
      }

      // 2. Firebase Signout
      await _auth.signOut();

      Get.delete<MyEventsController>(force: true); 
      Get.delete<HomeController>(force: true); 
      
    } catch (e) {
      Get.snackbar("Error", "Logout failed: $e");
    }
  }
}