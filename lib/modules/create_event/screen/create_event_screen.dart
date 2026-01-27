import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gift_collab/widgets/app_text_field.dart';
import 'package:gift_collab/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import '../controller/create_event_controller.dart';

class CreateEventScreen extends StatelessWidget {
  CreateEventScreen({super.key});

  final controller = Get.put(CreateEventController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Close keyboard
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Event"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              GestureDetector(
                onTap: controller.pickImage,
                child: Obx(
                  () => Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      image: controller.selectedImage.value != null
                          ? DecorationImage(
                              image: FileImage(controller.selectedImage.value!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: controller.selectedImage.value == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Upload Cover Image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Event Name (Required)
              AppTextField(
                controller: controller.titleController,
                label: "Event Name",
                prefixIcon: Icons.celebration,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: controller.descController,
                label: "Description",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date (Required)
              AppTextField(
                controller: TextEditingController(
                  text: DateFormat.yMMMd().format(
                    controller.selectedDate.value,
                  ),
                ),
                label: "Event Date",
                prefixIcon: Icons.calendar_today,
                isRequired: true,
                readOnly: true,
                onTap: () => controller.pickDate(context),
              ),
              const SizedBox(height: 16),

              // Location Name (Required)
              AppTextField(
                controller: controller.locationNameController,
                label: "Location Name",
                prefixIcon: Icons.location_on,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Location URL
              AppTextField(
                controller: controller.locationUrlController,
                label: "Location URL",
                prefixIcon: Icons.link,
                helperText: "Paste a Google Maps link (optional)",
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 30),

              // Invitation Link Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "INVITATION LINK (PREVIEW)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Obx(() {
                      final link = controller.invitationLink.value;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Link text
                          Expanded(
                            child: Text(
                              link,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Copy button
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: link.isEmpty
                                ? null
                                : () {
                                    Clipboard.setData(
                                      ClipboardData(text: link),
                                    );

                                    Get.snackbar(
                                      'Copied',
                                      'Invitation link copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 2),
                                    );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.copy,
                                size: 18,
                                color: link.isEmpty
                                    ? Colors.grey
                                    : AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 6),
                    const Text(
                      "This link will be active once the event is created.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Create Button

              Obx(
                () => CustomButton(text: 'Create Event', onPressed: controller.isLoading.value
                          ? (){}
                          : controller.createEvent,
                          isLoading: controller.isLoading.value,
                          ),
              )
              // SizedBox(
              //   width: double.infinity,
              //   height: 50,
              //   child: Obx(
              //     () => ElevatedButton(
                    // onPressed: controller.isLoading.value
                    //     ? null
                    //     : controller.createEvent,
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: AppColors.primaryPurple,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(30),
              //         ),
              //       ),
              //       child: controller.isLoading.value
              //           ? const CircularProgressIndicator(color: Colors.white)
              //           : const Text(
              //               "Create Event",
              //               style: TextStyle(fontSize: 16),
              //             ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
