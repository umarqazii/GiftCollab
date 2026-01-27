import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/event_model.dart';

class MyEventsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CHANGED: Future -> Stream
  Stream<List<EventModel>> getMyEventsStream() {
    final String? uid = _auth.currentUser?.uid;
    
    if (uid == null) return Stream.value([]); // Return empty stream if no user

    // CHANGED: .get() -> .snapshots()
    return _db
        .collection('events')
        .where('adminIds', arrayContains: uid)
        .orderBy('date', descending: false) 
        .snapshots() // <--- THIS IS THE MAGIC KEY
        .map((QuerySnapshot query) {
          List<EventModel> events = [];
          for (var doc in query.docs) {
            events.add(EventModel.fromMap(doc.data() as Map<String, dynamic>));
          }
          return events;
        });
  }
}