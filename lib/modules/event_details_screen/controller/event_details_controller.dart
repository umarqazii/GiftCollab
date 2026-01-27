import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/gift_model.dart';
import '../../../data/models/user_model.dart';
import '../../add_gift/screen/add_gift_screen.dart';
import '../../gift_registry/repository/gift_repository.dart';
import '../../invited_events/repository/invited_events_repository.dart';

// Helper class to unify Joined Users vs Invited Emails
class Participant {
  final String name;
  final String email;
  final String photoUrl;
  final String status; // 'Joined' or 'Invited'
  final bool isUser;   // True if it's a real account, False if just an email invite

  Participant({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.status,
    required this.isUser,
  });
}

class EventDetailsController extends GetxController {
  late EventModel event;
  var isAdmin = false.obs;
  var currentUid = "".obs;

  var isInvited = false.obs;
  var isJoined = false.obs;
  var isProcessing = false.obs;

  final InvitedEventsRepository _repo = InvitedEventsRepository();
  
  // The unified list of people
  var participants = <Participant>[].obs;
  var isLoadingParticipants = true.obs;

  final GiftRepository _giftRepo = GiftRepository();
  var previewGifts = <GiftModel>[].obs;
  var isLoadingGifts = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is EventModel) {
      event = Get.arguments as EventModel;
    } else {
      Get.back();
      return;
    }
    
    currentUid.value = FirebaseAuth.instance.currentUser?.uid ?? "";
    isAdmin.value = event.adminIds.contains(currentUid.value);
    
    // Load the people list
    fetchParticipants();

    _checkUserStatus();
    _setupGiftListener();
  }

  void _setupGiftListener() {
    isLoadingGifts.value = true;
    previewGifts.bindStream(_giftRepo.getGiftsStream(event.id));
    ever(previewGifts, (_) => isLoadingGifts.value = false);
  }

  void onViewAllGiftsPressed() {
    // We will create this route next
    Get.toNamed('/gift-registry', arguments: event);
  }

  void _checkUserStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUid.value = user.uid;

      // Check Roles
      isAdmin.value = event.adminIds.contains(user.uid);
      isJoined.value = event.joinedUserIds.contains(user.uid);
      isInvited.value = event.invitedEmails.contains(user.email);
    }
  }

  Future<void> acceptInvite() async {
    try {
      isProcessing.value = true;
      await _repo.acceptInvitation(event.id);

      // Update Local State so UI changes instantly
      isInvited.value = false;
      isJoined.value = true;

      // Refresh the "People" list to show yourself as Joined
      event.invitedEmails.remove(FirebaseAuth.instance.currentUser?.email);
      event.joinedUserIds.add(currentUid.value);
      fetchParticipants();

      Get.snackbar("Success", "You have joined the event!");
    } catch (e) {
      Get.snackbar("Error", "Could not accept invitation");
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> declineInvite() async {
    try {
      isProcessing.value = true;
      await _repo.declineInvitation(event.id);
      Get.back(); // Close screen since you aren't part of it anymore
      Get.snackbar("Declined", "Invitation removed.");
    } catch (e) {
      Get.snackbar("Error", "Could not decline invitation");
    } finally {
      isProcessing.value = false;
    }
  }
  
  void onAddGiftPressed() {
    Get.to(() => AddGiftScreen(eventId: event.id));
  }
// ... existing variables ...

  // 1. The Dialog Logic
  void onAddPeoplePressed() {
    final TextEditingController emailInput = TextEditingController();
    
    Get.defaultDialog(
      title: "Invite Guest",
      contentPadding: const EdgeInsets.all(20),
      titlePadding: const EdgeInsets.only(top: 20),
      content: Column(
        children: [
          const Text("Enter the email address of the person you want to invite."),
          const SizedBox(height: 16),
          TextField(
            controller: emailInput,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
        ],
      ),
      textConfirm: "Invite",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.deepPurple, // Use AppColors.primaryPurple if available
      onConfirm: () {
        if (emailInput.text.isEmail) {
          Get.back(); // Close dialog
          _sendInviteToFirestore(emailInput.text.trim());
        } else {
          Get.snackbar("Error", "Please enter a valid email");
        }
      },
    );
  }

  // 2. The Database Logic
  Future<void> _sendInviteToFirestore(String email) async {
    try {
      // 1. Check if the user is already invited
      if (event.invitedEmails.contains(email)) {
        Get.snackbar("Notice", "$email is already invited.");
        return;
      }

      // 2. Check if the user has already joined
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        final String uid = userDoc['uid']; // or userDoc.id

        if (event.joinedUserIds.contains(uid)) {
          Get.snackbar("Notice", "User has already joined this event!");
          return;
        }
      }

      // 3. If we passed both checks, it's safe to invite!
      await FirebaseFirestore.instance.collection('events').doc(event.id).update({
        'invitedEmails': FieldValue.arrayUnion([email])
      });

      event.invitedEmails.add(email);

      fetchParticipants();

      Get.snackbar("Success", "Invitation sent to $email");

    } catch (e) {
      Get.snackbar("Error", "Failed to send invite: $e");
    }
  }

  Future<void> fetchParticipants() async {
    try {
      isLoadingParticipants.value = true;
      List<Participant> tempList = [];

      // 1. PROCESS INVITED EMAILS (Smart Lookup)
      for (String email in event.invitedEmails) {
        
        // Query Firestore to see if a user with this email already exists
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          // FOUND! Use their profile details
          final user = UserModel.fromJson(userQuery.docs.first.data() as Map<String, dynamic>);
          
          tempList.add(Participant(
            name: user.displayName, // Use actual name
            email: email,
            photoUrl: user.photoUrl, // Use actual photo
            status: "Invited",
            isUser: true,
          ));
        } else {
          // NOT FOUND! Fallback to "Guest"
          tempList.add(Participant(
            name: "Guest",
            email: email,
            photoUrl: "",
            status: "Invited",
            isUser: false,
          ));
        }
      }

      // 2. PROCESS JOINED USERS (Existing logic)
      if (event.joinedUserIds.isNotEmpty) {
        for (String uid in event.joinedUserIds) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (doc.exists) {
            final user = UserModel.fromJson(doc.data()!);
            
            // Avoid duplicates: If a user is both "Invited" (via email) and "Joined" (via UID),
            // we prefer the "Joined" status.
            // We remove any existing entry with the same email from the list before adding the Joined version.
            tempList.removeWhere((p) => p.email == user.email);

            tempList.add(Participant(
              name: user.displayName,
              email: user.email,
              photoUrl: user.photoUrl,
              status: "Joined",
              isUser: true,
            ));
          }
        }
      }

      participants.assignAll(tempList);
      
    } catch (e) {
      print("Error loading participants: $e");
    } finally {
      isLoadingParticipants.value = false;
    }
  }
  void resendInvitation(String email) {
    // Logic to resend email (requires Cloud Functions or external email API)
    Get.snackbar("Invitation Sent", "Reminder sent to $email");
  }
}