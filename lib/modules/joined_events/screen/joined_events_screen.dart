import 'package:cached_network_image/cached_network_image.dart';
import 'package:gift_collab/core/constants/app_assets.dart';
import 'package:gift_collab/modules/event_details_screen/screen/event_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import '../../../data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/modules/joined_events/controller/joined_events_controller.dart';

class JoinedEventsScreen extends StatelessWidget {
  JoinedEventsScreen({super.key});

  final JoinedEventsController controller = Get.put(JoinedEventsController());

  @override
  Widget build(BuildContext context) {
    final JoinedEventsController controller = Get.put(JoinedEventsController());
    return Scaffold(
      body: Obx(() {
        // 1. Loading State
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Empty State
        if (controller.joinedEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Events Joined Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 3. List of Events
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.joinedEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final event = controller.joinedEvents[index];
            return _buildEventCard(event);
          },
        );
      }),


    );
  }

  Widget _buildEventCard(EventModel event) {
    // Check if we have a valid URL
    final hasImage = event.imageUrl.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures image corners align with card
      child: InkWell(
        onTap: () {
          // Navigate to Event Details Screen with event data
          Get.to(() => EventDetailsScreen(), arguments: event);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION ---
            SizedBox(
              height: 150,
              width: double.infinity,
              child: hasImage
                  ? CachedNetworkImage(
                imageUrl: event.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
                  : _buildPlaceholder(),
            ),

            // --- DETAILS SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date Row
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat.yMMMd().format(event.date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location Row
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.locationName,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryPurple.withOpacity(0.1),
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        AppAssets.eventPlaceholder,
        fit: BoxFit.cover, // Fill the space like CachedNetworkImage
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}