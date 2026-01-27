import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gift_collab/routes/app_routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/models/user_model.dart';
// import '../../routes/app_routes.dart'; // Uncomment when routes are ready

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); 
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Force account picker
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _checkAndCreateUser(user);
        
        Get.snackbar("Success", "Welcome ${user.displayName}");
        //  Get.offAllNamed(Routes().getHomeScreen()); 
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkAndCreateUser(User user) async {
    final userDoc = await _db.collection('users').doc(user.uid).get();
    
    if (!userDoc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL ?? '',
      );
      await _db.collection('users').doc(user.uid).set(newUser.toJson());
    }
  }
}