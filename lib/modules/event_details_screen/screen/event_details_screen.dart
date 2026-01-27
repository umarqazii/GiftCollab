import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/core/constants/app_assets.dart';
import '../../../data/models/gift_model.dart';
import '../controller/event_details_controller.dart';

class EventDetailsScreen extends StatelessWidget {
  EventDetailsScreen({super.key});

  final controller = Get.put(EventDetailsController());

  @override
  Widget build(BuildContext context) {
    // Safety check: if controller init failed (no arguments), don't build
    if (!Get.isRegistered<EventDetailsController>()) return const SizedBox();

    final event = controller.event;
    final hasImage = event.imageUrl.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Collapsing Header with Image
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? CachedNetworkImage(
                          imageUrl: event.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                  // Dark gradient overlay for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Date & Location ---
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMMEEEEd().format(event.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.locationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Admin Only: Invite Code ---
                  Obx(() {
                    if (controller.isAdmin.value) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Invitation Code",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  event.invitationCode,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: event.invitationCode),
                                );
                                Get.snackbar(
                                  "Copied",
                                  "Code copied to clipboard!",
                                );
                              },
                              icon: const Icon(Icons.copy, color: Colors.amber),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // --- Description ---
                  const Text(
                    "About Event",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description.isEmpty
                        ? "No description provided."
                        : event.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Gift Registry Section (Placeholder) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Gift Registry",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                      // "View All" Button (Visible to everyone)
                      Row(
                        children: [
                          TextButton(
                            onPressed: controller.onViewAllGiftsPressed,
                            child: const Text(
                              "View All",
                              style: TextStyle(color: AppColors.primaryPurple),
                            ),
                          ),

                          if (controller.isAdmin.value)
                            TextButton(
                              onPressed: controller.onAddGiftPressed,
                              child: const Text(
                                "Add Gift",
                                style: TextStyle(color: AppColors.primaryPurple),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),

                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- GIFT CAROUSEL (The Preview) ---
                  SizedBox(
                    height: 180, // Height of the carousel
                    child: Obx(() {
                      if (controller.isLoadingGifts.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.previewGifts.isEmpty) {
                        // Empty State (Admin sees "Add", Guests see "Empty")
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.card_giftcard, size: 40, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Text(controller.isAdmin.value
                                  ? "Add your first gift!"
                                  : "No gifts added yet.",
                                  style: TextStyle(color: Colors.grey[500])),
                              if (controller.isAdmin.value)
                                TextButton.icon(
                                  onPressed: controller.onAddGiftPressed,
                                  icon: const Icon(Icons.add_circle, size: 16),
                                  label: const Text("Add Gift"),
                                )
                            ],
                          ),
                        );
                      }

                      final giftsToShow = controller.previewGifts.length > 3
                          ? controller.previewGifts.take(3).toList()
                          : controller.previewGifts;

                      // The List
                      return PageView.builder(
                        controller: PageController(
                          viewportFraction: giftsToShow.length == 1 ? 1.0 : 0.95,
                        ),
                        itemCount: giftsToShow.length,
                        itemBuilder: (context, index) {
                          final gift = giftsToShow[index];
                          return Padding(
                            padding: giftsToShow.length == 1
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(right: 12),
                            child: _buildGiftPreviewCard(gift),
                          );
                        },
                      );


                    }),
                  ),
                  const SizedBox(height: 32),

                  // --- PEOPLE SECTION ---
                  Obx(() {
                    final isAdmin = controller.isAdmin.value;
                    final participants = controller.participants;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "People",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "(${participants.length})",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (isAdmin)
                              TextButton.icon(
                                onPressed: controller.onAddPeoplePressed,
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text("Invite"),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryPurple,
                                ),
                              ),
                          ],
                        ),

                        // Loading
                        if (controller.isLoadingParticipants.value)
                          const Center(child: CircularProgressIndicator())
                        // Empty state
                        else if (participants.isEmpty)
                          Text(
                            "No one has joined yet.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          )
                        // List
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: participants.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final person = participants[index];
                                final isJoined = person.status == "Joined";

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage:
                                          person.photoUrl.isNotEmpty
                                          ? CachedNetworkImageProvider(
                                              person.photoUrl,
                                            )
                                          : null,
                                      child: person.photoUrl.isEmpty
                                          ? Text(
                                              person.name.isNotEmpty
                                                  ? person.name[0].toUpperCase()
                                                  : "G",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : null,
                                    ),

                                    const SizedBox(width: 12),

                                    // Name & email
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            person.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            person.email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Status + action
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isJoined
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            person.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isJoined
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),

                                        if (!isJoined && isAdmin)
                                          GestureDetector(
                                            onTap: () => controller
                                                .resendInvitation(person.email),
                                            child: const Padding(
                                              padding: EdgeInsets.only(top: 6),
                                              child: Text(
                                                "Resend",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.primaryPurple,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
                    );
                  }),
                  // Extra space at bottom
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Obx(() {
        if (!controller.isInvited.value) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : controller.declineInvite,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : controller.acceptInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: controller.isProcessing.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text("Accept Invitation"),
                  ),
                ),
              ],
            ),
          ),
        );
      }),

    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(AppAssets.eventPlaceholder, fit: BoxFit.cover);
  }

  // 1. The Standard Gift Card
  Widget _buildGiftPreviewCard(GiftModel gift) {
    final hasImage = gift.imageUrl.isNotEmpty;
    // Calculate progress for the bar
    final double percent = (gift.amountCollected / gift.price).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: hasImage
                ? CachedNetworkImage(imageUrl: gift.imageUrl, fit: BoxFit.cover, width: double.infinity)
                : Container(color: AppColors.primaryPurple.withOpacity(0.1), child: const Center(child: Icon(Icons.image, color: Colors.grey))),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(gift.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),

                  // Mini Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[100],
                        color: percent >= 1.0 ? Colors.green : AppColors.primaryPurple,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        percent >= 1.0 ? "FUNDED" : "\$${(gift.price - gift.amountCollected).toInt()} to go",
                        style: TextStyle(fontSize: 10, color: percent >= 1.0 ? Colors.green : Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



}
