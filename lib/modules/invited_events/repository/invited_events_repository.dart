import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/event_model.dart';

class InvitedEventsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<EventModel>> getInvitedEventsStream() {
    final String? email = _auth.currentUser?.email;
    
    // Safety check: If user has no email, they can't have email-based invites
    if (email == null || email.isEmpty) return Stream.value([]); 

    return _db
        .collection('events')
        .where('invitedEmails', arrayContains: email)
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

  // Action: Accept Invitation
  Future<void> acceptInvitation(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Atomic Operation: Remove email from invited, Add UID to joined
    await _db.collection('events').doc(eventId).update({
      'invitedEmails': FieldValue.arrayRemove([user.email]),
      'joinedUserIds': FieldValue.arrayUnion([user.uid]),
    });
  }

  // Action: Decline Invitation
  Future<void> declineInvitation(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Atomic Operation: Just remove the email
    await _db.collection('events').doc(eventId).update({
      'invitedEmails': FieldValue.arrayRemove([user.email]),
    });
  }
}