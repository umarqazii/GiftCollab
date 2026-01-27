import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import '../../../data/models/gift_model.dart';
import '../controller/gift_registry_controller.dart';
import '../widgets/contributor_hint_icon.dart';

class GiftRegistryScreen extends StatelessWidget {
  static const String id = '/gift-registry';
  GiftRegistryScreen({super.key});

  final controller = Get.put(GiftRegistryController());

  @override
  Widget build(BuildContext context) {
    // Safety check if controller failed to init
    if (!Get.isRegistered<GiftRegistryController>()) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift Registry"),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          // Only Admins can add new gifts
          Obx(() => controller.isAdmin.value
              ? IconButton(
            onPressed: controller.onAddGiftPressed,
            icon: const Icon(Icons.add),
            tooltip: "Add Gift",
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.gifts.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.gifts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final gift = controller.gifts[index];
            // Pass admin status to the card builder
            return _buildGiftCard(gift, controller.isAdmin.value);
          },
        );
      }),
    );
  }

  Widget _buildGiftCard(GiftModel gift, bool isAdmin) {
    final hasImage = gift.imageUrl.isNotEmpty;
    // Calculate progress: ensure it's between 0.0 and 1.0
    final double percent = (gift.amountCollected / gift.price).clamp(0.0, 1.0);
    final bool isFunded = percent >= 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image & Category Badge (Same as before)
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: hasImage
                    ? CachedNetworkImage(
                  imageUrl: gift.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[100]),
                  errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                )
                    : Container(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  child: const Center(child: Icon(Icons.card_giftcard, size: 50, color: Colors.grey)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    gift.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: ContributorsHintIcon(
                  onTap: () => controller.onViewContributorsPressed(gift),
                ),
              ),
            ],
          ),

          // 2. Details, Progress Bar & Action
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        gift.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "\$${gift.price.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- THE RETURN OF THE PROGRESS BAR ---
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.grey[100],
                  // Turn green if fully funded
                  color: isFunded ? Colors.green : AppColors.primaryPurple,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),

                // Progress Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${gift.amountCollected.toStringAsFixed(0)} collected",
                      style: TextStyle(
                        color: isFunded ? Colors.green[700] : Colors.grey[700],
                        fontWeight: isFunded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      isFunded ? "FULLY FUNDED" : "\$${(gift.price - gift.amountCollected).toStringAsFixed(0)} to go",
                      style: TextStyle(
                          color: isFunded ? Colors.green[700] : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Action Button (Model B Logic - Cash Fund)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: isFunded
                  // State: FULLY FUNDED
                      ? ElevatedButton.icon(
                    onPressed: null, // Disabled
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      disabledBackgroundColor: Colors.green.shade100,
                      disabledForegroundColor: Colors.green.shade800,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Fully Funded!"),
                  )
                  // State: NEEDS FUNDING (Show Contribute button for Guests)
                      : !isAdmin
                      ? ElevatedButton(
                    // THIS IS THE NEW ACTION
                    onPressed: () => controller.onContributePressed(gift),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Contribute"),
                  )
                  // Admins see a disabled "Funding in Progress" button
                      : OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300)
                    ),
                    child: const Text("Funding in Progress", style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // (Keep the _buildEmptyState widget the same as before)
  Widget _buildEmptyState() {
    // ... (same code as previous response) ...
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Registry is empty.",
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            "Admins can add gifts using the '+' button above.",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}