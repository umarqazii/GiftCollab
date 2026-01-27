import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import '../controller/add_gift_controller.dart';

class AddGiftScreen extends StatelessWidget {
  final String eventId;
  const AddGiftScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // Inject controller with the eventId
    final controller = Get.put(AddGiftController(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text("Add a Gift")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Picker
            GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() => Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: controller.selectedImage.value != null
                      ? DecorationImage(
                    image: FileImage(controller.selectedImage.value!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: controller.selectedImage.value == null
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                    : null,
              )),
            ),
            const SizedBox(height: 20),

            // Name
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: "Gift Name (e.g. Dyson Vacuum)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            TextField(
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Price",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            TextField(
              controller: controller.categoryController,
              decoration: const InputDecoration(
                labelText: "Category (Optional)",
                hintText: "e.g. Kitchen, Travel",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add to Registry"),
              )),
            ),
          ],
        ),
      ),
    );
  }
}