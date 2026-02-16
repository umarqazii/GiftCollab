import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthService> init() async {
    // Just ensure Firebase is ready. We don't navigate here anymore.
    return this;
  }

  // Helper to get current user easily
  User? get currentUser => _auth.currentUser;
}