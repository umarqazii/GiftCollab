import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/gift_model.dart';

class GiftRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for the "Carousel" (Preview)
  Stream<List<GiftModel>> getGiftsStream(String eventId) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .orderBy('price', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GiftModel.fromMap(doc.data()))
        .toList());
  }
}