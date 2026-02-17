import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the current user's profile from Firestore. Returns null if not found.
  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()! as Map<String, dynamic>);
  }

  /// Updates the current user's shop info in Firestore (merge so other fields stay).
  Future<void> updateShopInfo({
    required String shopName,
    required String shopDisplayPicUrl,
    required String shopCategory,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');
    await _db.collection('users').doc(uid).set({
      'shopName': shopName,
      'shopDisplayPicUrl': shopDisplayPicUrl,
      'shopCategory': shopCategory,
    }, SetOptions(merge: true));
  }

  /// Stream of all users who have a shop (for marketplace listing).
  /// Firestore may require a composite index for orderBy + isNotEqualTo.
  Stream<List<UserModel>> getShopsStream() {
    return _db
        .collection('users')
        .where('shopName', isNotEqualTo: '')
        .orderBy('shopName')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => UserModel.fromJson({
                  ...?doc.data(),
                  'uid': doc.id,
                } as Map<String, dynamic>))
            .toList());
  }
}
