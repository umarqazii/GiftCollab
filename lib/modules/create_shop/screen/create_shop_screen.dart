import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_categories.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/modules/create_shop/controller/create_shop_controller.dart';

class CreateShopScreen extends GetView<CreateShopController> {
  static const String id = '/create_shop';
  const CreateShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your shop'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Set up your shop so buyers can find you. You can filter by shop or category when adding gifts.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Shop display image
            GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() {
                final file = controller.selectedImage.value;
                return Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: file != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(file, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to add shop image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop name',
                border: OutlineInputBorder(),
                hintText: 'e.g. My Gift Store',
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCategory.value,
              decoration: const InputDecoration(
                labelText: 'Shop category',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select category'),
              items: AppCategories.shopAndProductCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => controller.selectedCategory.value = v,
            )),
            const SizedBox(height: 28),
            Obx(() {
              final saving = controller.isSaving.value;
              return SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : controller.createShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create shop'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
