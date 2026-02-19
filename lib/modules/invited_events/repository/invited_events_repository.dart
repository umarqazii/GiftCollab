import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/event_model.dart';

class InvitedEventsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static String _normalizeEmail(String? email) {
    return email?.trim().toLowerCase() ?? '';
  }

  /// Returns a stream of events that list the current user's email in invitedEmails.
  /// Driven by auth state: when the user (and email) becomes available, the Firestore
  /// query runs. Uses normalized (lowercase) email so matching works regardless of case.
  Stream<List<EventModel>> getInvitedEventsStream() {
    return _auth.authStateChanges().asyncExpand((User? user) async* {
      if (user == null) {
        yield [];
        return;
      }

      // Ensure profile is loaded (fixes race where email isn't set yet after sign-in)
      var email = _normalizeEmail(user.email);
      if (email.isEmpty) {
        try {
          await user.reload();
          final refreshed = _auth.currentUser;
          email = _normalizeEmail(refreshed?.email);
        } catch (_) {
          yield [];
          return;
        }
      }

      if (email.isEmpty) {
        yield [];
        return;
      }

      yield* _getInvitedEventsStreamForEmail(email);
    });
  }

  Stream<List<EventModel>> _getInvitedEventsStreamForEmail(String normalizedEmail) {
    return _db
        .collection('events')
        .where('invitedEmails', arrayContains: normalizedEmail)
        .orderBy('date', descending: false)
        .snapshots()
        .map((QuerySnapshot query) {
          return query.docs
              .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  /// Find the exact invitedEmails entry that matches the current user (case-insensitive)
  /// so we can remove it even if it was stored with different casing (legacy data).
  Future<String?> _findStoredInvitedEmail(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final currentEmailLower = _normalizeEmail(user.email);
    if (currentEmailLower.isEmpty) return null;

    final doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    final list = data?['invitedEmails'] as List<dynamic>?;
    if (list == null) return null;
    for (final e in list) {
      final s = e?.toString().trim() ?? '';
      if (s.toLowerCase() == currentEmailLower) return s;
    }
    return null;
  }

  Future<void> acceptInvitation(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final storedEmail = await _findStoredInvitedEmail(eventId);
    if (storedEmail == null) {
      // Fallback: try removing normalized email (for consistently stored lowercase)
      await _db.collection('events').doc(eventId).update({
        'invitedEmails': FieldValue.arrayRemove([user.email!.trim().toLowerCase()]),
        'joinedUserIds': FieldValue.arrayUnion([user.uid]),
      });
      return;
    }

    await _db.collection('events').doc(eventId).update({
      'invitedEmails': FieldValue.arrayRemove([storedEmail]),
      'joinedUserIds': FieldValue.arrayUnion([user.uid]),
    });
  }

  Future<void> declineInvitation(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final storedEmail = await _findStoredInvitedEmail(eventId);
    if (storedEmail == null) {
      await _db.collection('events').doc(eventId).update({
        'invitedEmails': FieldValue.arrayRemove([user.email!.trim().toLowerCase()]),
      });
      return;
    }

    await _db.collection('events').doc(eventId).update({
      'invitedEmails': FieldValue.arrayRemove([storedEmail]),
    });
  }
}
