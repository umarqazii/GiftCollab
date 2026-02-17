import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/core/constants/app_categories.dart';
import 'package:gift_collab/core/constants/app_colors.dart';
import '../controller/seller_product_controller.dart';
import '../../../../data/models/product_model.dart';

class SellerProductScreen extends StatelessWidget {
  SellerProductScreen({super.key});

  final SellerProductController controller = Get.put(SellerProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        // 1. Loading state (like My Events)
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Empty state
        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No products listed yet.\nAdd one to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 3. Product grid
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            childAspectRatio: 0.75, // Taller cards
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return _buildProductCard(product);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductSheet(context),
        label:  Text("Add Product", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.broken_image),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("\$${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stock: ${product.inventory}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    // Urgency Badge
                    if (product.addedByCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text("🔥 ${product.addedByCount} active", style: const TextStyle(fontSize: 10, color: Colors.deepOrange)),
                      )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        height: Get.height * 0.85, // Tall sheet
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("List New Item", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Image Picker
              GestureDetector(
                onTap: controller.pickImage,
                child: Obx(() => Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: controller.selectedImage.value != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover))
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.camera_alt, size: 40, color: Colors.grey), Text("Tap to upload image")],
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(controller: controller.nameController, decoration: const InputDecoration(labelText: "Product Name", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: controller.descController, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedProductCategory.value,
                decoration: const InputDecoration(labelText: "Product category", border: OutlineInputBorder()),
                hint: const Text("Select category"),
                items: AppCategories.shopAndProductCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => controller.selectedProductCategory.value = v,
              )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: controller.priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (\$)", border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: controller.inventoryController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Inventory Qty", border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() {
                  final uploading = controller.isUploading.value;
                  return ElevatedButton(
                    onPressed: uploading ? null : controller.uploadProduct,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, foregroundColor: Colors.white),
                    child: uploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("List Item"),
                  );
                }),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}