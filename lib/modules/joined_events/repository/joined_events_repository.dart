import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/event_model.dart';

class JoinedEventsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<EventModel>> getJoinedEventsStream() {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) return Stream.value([]);

    return _db
        .collection('events')
        .where('joinedUserIds', arrayContains: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((QuerySnapshot query) {
      List<EventModel> events = [];
      for (var doc in query.docs) {
        events.add(EventModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return events;
    });
  }
}