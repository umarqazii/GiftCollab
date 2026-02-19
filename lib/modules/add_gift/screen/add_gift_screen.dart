import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import 'package:gift_collab/data/models/product_model.dart';
import '../controller/add_gift_controller.dart';

class AddGiftScreen extends StatelessWidget {
  final String eventId;
  const AddGiftScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddGiftController(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a Gift"),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.primaryPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryPurple,
              tabs: [
                Tab(text: "Custom"),
                Tab(text: "From shop"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CustomGiftTab(controller: controller),
                  _FromShopTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomGiftTab extends StatelessWidget {
  final AddGiftController controller;

  const _CustomGiftTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: "Gift name (e.g. Dyson Vacuum)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Total price",
              prefixText: "\$ ",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.categoryController,
            decoration: const InputDecoration(
              labelText: "Category (optional)",
              hintText: "e.g. Kitchen, Travel",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
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
                      : const Text("Add to registry"),
                )),
          ),
        ],
      ),
    );
  }
}

class _FromShopTab extends StatelessWidget {
  final AddGiftController controller;

  const _FromShopTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Enter the product code from the marketplace (e.g. GC-A1B2C3D4). You can copy it from the product detail in a shop.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.productCodeSearchController,
                  decoration: const InputDecoration(
                    labelText: "Product code",
                    hintText: "GC-XXXXXXXX",
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => controller.searchByCode(),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isSearching.value ? null : controller.searchByCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: controller.isSearching.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Search"),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            final product = controller.searchResult.value;
            if (product == null) {
              return const SizedBox.shrink();
            }
            return _ProductResultCard(
              product: product,
              onAdd: controller.addProductFromMarketplace,
              onClear: controller.clearSearch,
              isLoading: controller.isLoading.value,
            );
          }),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAdd;
  final VoidCallback onClear;
  final bool isLoading;

  const _ProductResultCard({
    required this.product,
    required this.onAdd,
    required this.onClear,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                          )
                        : const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      if (product.shopName.isNotEmpty)
                        Text(
                          product.shopName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryPurple),
                  child: const Text("Clear"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Add to registry"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
