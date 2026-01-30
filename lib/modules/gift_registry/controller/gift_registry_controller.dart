import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/gift_model.dart';
import '../../../data/models/user_model.dart';
import '../../add_gift/screen/add_gift_screen.dart';
import '../repository/gift_repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';

class GiftRegistryController extends GetxController {
  final GiftRepository _repository = GiftRepository();

  // Data passed from the previous screen
  late EventModel event;

  // State
  var gifts = <GiftModel>[].obs;
  var isLoading = true.obs;
  var isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _setupListener();
  }

  void _loadArguments() {
    // Ensure we received the event object
    if (Get.arguments != null && Get.arguments is EventModel) {
      event = Get.arguments as EventModel;

      // Determine if current user is an admin of this event
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      isAdmin.value = event.adminIds.contains(currentUid);

    } else {
      // Handle error if navigated here incorrectly
      Get.back();
      Get.snackbar("Error", "Could not load registry");
    }
  }

  void _setupListener() {
    isLoading.value = true;
    // Bind the list to the Firestore stream for real-time updates
    gifts.bindStream(_repository.getGiftsStream(event.id));

    // Turn off loading once data starts flowing
    ever(gifts, (_) {
      isLoading.value = false;
    });
  }

  void onAddGiftPressed() {
    Get.to(() => AddGiftScreen(eventId: event.id));
  }

  void onContributePressed(GiftModel gift) {
    final amountController = TextEditingController();
    final messageController = TextEditingController();

    Get.defaultDialog(
      title: "Contribute to ${gift.name}",
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          // Amount Input
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Amount (\$)",
              prefixText: "\$ ",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Message Input
          TextField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: "Message (Optional)",
              hintText: "Best wishes!",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          const Text(
            "Note: This is a simulation. No real money will be charged.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      textConfirm: "Pay Now",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green, // Money color!
      onConfirm: () {
        final amount = double.tryParse(amountController.text);
        if (amount == null || amount <= 0) {
          Get.snackbar("Error", "Please enter a valid amount");
          return;
        }

        // Check if amount exceeds remaining cost (optional, but good UX)
        double remaining = gift.price - gift.amountCollected;
        if (amount > remaining) {
          Get.snackbar("Whoops", "Maximum needed is \$${remaining.toStringAsFixed(0)}");
          return;
        }

        Get.back(); // Close dialog
        _processContribution(gift, amount, messageController.text);
      },
    );
  }

  Future<void> _processContribution(GiftModel gift, double amount, String message) async {
    try {
      isLoading.value = true;

      // --- STEP 1: Talk to your Node Server ---
      // Convert dollars to cents (Stripe expects integers)
      final int amountInCents = (amount * 100).toInt();

      // REPLACE this URL with your actual server URL:
      // - Android Emulator: 'http://10.0.2.2:3000/create-payment-intent'
      // - iOS Simulator:    'http://localhost:3000/create-payment-intent'
      // - Real Device:      'http://<YOUR_PC_IP>:3000/create-payment-intent'
      // - Render/Live:      'https://giftcollab-api.onrender.com/create-payment-intent'
      final url = Uri.parse('https://giftcollab-server.onrender.com/create-payment-intent');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountInCents,
          'currency': 'usd', // Change currency if needed
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Server connection failed: ${response.body}");
      }

      final jsonResponse = jsonDecode(response.body);

      // This is the "secret handshake" key from Stripe
      final clientSecret = jsonResponse['clientSecret'];

      // --- STEP 2: Initialize the Payment Sheet ---
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GiftCollab', // Shown on the sheet
          style: ThemeMode.light,
          // billingDetails: const BillingDetails(name: 'Your User Name'), // Optional pre-fill
        ),
      );

      // --- STEP 3: Show the Sheet to the User ---
      // This line pauses execution until the user finishes paying or cancels
      await Stripe.instance.presentPaymentSheet();

      // ==================================================
      // IF WE REACH HERE, THE PAYMENT WAS SUCCESSFUL!
      // ==================================================

      // --- STEP 4: Record the Contribution in Firestore ---
      // We perform the database update NOW, because we know the money is safe.
      await _recordContributionInFirestore(gift, amount, message);

      Get.snackbar("Success", "Payment confirmed! Thank you for contributing.");

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // User closed the sheet without paying - silent return or soft message
        Get.snackbar("Cancelled", "Payment flow cancelled");
      } else {
        Get.snackbar("Payment Error", e.error.localizedMessage ?? "Unknown Stripe error");
      }
    } catch (e) {
      // General error (Network, Server, or Code)
      print("System Error: $e");
      Get.snackbar("Error", "Transaction failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper Function: The Database Logic (Separated for cleanliness)
  Future<void> _recordContributionInFirestore(GiftModel gift, double amount, String message) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1. Prepare Data
    String userName = currentUser.displayName ?? "Anonymous";
    String userPhoto = currentUser.photoURL ?? "";
    final contributionId = const Uuid().v4();

    final newContribution = ContributionModel(
      id: contributionId,
      giftId: gift.id,
      userId: currentUser.uid,
      userName: userName,
      userPhotoUrl: userPhoto,
      amount: amount,
      timestamp: DateTime.now(),
      message: message.isEmpty ? null : message,
    );

    // 2. Run Transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference giftRef = FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .collection('gifts')
          .doc(gift.id);

      DocumentSnapshot giftSnapshot = await transaction.get(giftRef);

      if (!giftSnapshot.exists) throw Exception("Gift not found");

      final data = giftSnapshot.data() as Map<String, dynamic>;
      double currentCollected = (data['amountCollected'] as num?)?.toDouble() ?? 0.0;
      double price = (data['price'] as num?)?.toDouble() ?? 0.0;

      double newCollected = currentCollected + amount;
      bool isFullyFunded = newCollected >= price;

      // Write Contribution
      DocumentReference contributionRef = giftRef.collection('contributions').doc(contributionId);
      transaction.set(contributionRef, newContribution.toJson());

      // Update Gift Totals
      transaction.update(giftRef, {
        'amountCollected': newCollected,
        'isFullyFunded': isFullyFunded,
      });
    });
  }

  void onViewContributorsPressed(GiftModel gift) {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.75, // 👈 75% of screen
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.people, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Contributors for ${gift.name}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),

              // Scrollable list stays inside the capped height
              Expanded(
                child: StreamBuilder<List<ContributionModel>>(
                  stream: _repository.getContributionsStream(event.id, gift.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final contributions = snapshot.data ?? [];

                    if (contributions.isEmpty) {
                      return Center(
                        child: Text(
                          "No contributions yet.\nBe the first!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: contributions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final contrib = contributions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: contrib.userPhotoUrl.isNotEmpty
                                ? NetworkImage(contrib.userPhotoUrl)
                                : null,
                            child: contrib.userPhotoUrl.isEmpty
                                ? Text(contrib.userName[0])
                                : null,
                          ),
                          title: Text(
                            contrib.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: contrib.message != null
                              ? Text(
                            '"${contrib.message}"',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          )
                              : null,
                          trailing: Text(
                            "+\$${contrib.amount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }


}