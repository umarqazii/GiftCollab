import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/gift_model.dart';
import '../../../data/models/product_model.dart';
import '../../seller_products/repository/seller_product_repository.dart';

class AddGiftController extends GetxController {
  final String eventId;
  final SellerProductRepository _productRepository = SellerProductRepository();

  AddGiftController(this.eventId);

  // Custom gift form
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final productCodeSearchController = TextEditingController();

  var selectedImage = Rxn<File>();
  var isLoading = false.obs;
  var isSearching = false.obs;
  var searchResult = Rxn<ProductModel>();

  final cloudinary = CloudinaryPublic('ddbllhkcb', 'giftcollab_preset', cache: false);

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    categoryController.dispose();
    productCodeSearchController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage.value = File(image.path);
  }

  Future<String> _uploadToCloudinary(File image) async {
    CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
    );
    return response.secureUrl;
  }

  /// Search for a product by its human-readable code (e.g. GC-A1B2C3D4).
  Future<void> searchByCode() async {
    final code = productCodeSearchController.text.trim();
    if (code.isEmpty) {
      Get.snackbar("Error", "Enter a product code");
      return;
    }
    try {
      isSearching.value = true;
      searchResult.value = null;
      final product = await _productRepository.getProductByCode(code);
      searchResult.value = product;
      if (product == null) {
        Get.snackbar("Not found", "No product found with that code");
      }
    } catch (e) {
      Get.snackbar("Error", "Search failed: $e");
    } finally {
      isSearching.value = false;
    }
  }

  /// Add the currently found marketplace product as a gift to the registry.
  Future<void> addProductFromMarketplace() async {
    final product = searchResult.value;
    if (product == null) {
      Get.snackbar("Error", "Search for a product first");
      return;
    }

    try {
      isLoading.value = true;
      final giftId = const Uuid().v4();
      final newGift = GiftModel(
        id: giftId,
        name: product.name,
        price: product.price,
        amountCollected: 0.0,
        imageUrl: product.imageUrl,
        category: product.productCategory.isNotEmpty ? product.productCategory : "General",
        isFullyFunded: false,
        productId: product.id,
        productCode: product.productCode,
        sellerId: product.sellerId,
        shopName: product.shopName,
        shopCategory: product.shopCategory,
      );

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .set(newGift.toJson());

      await _productRepository.incrementAddedByCount(product.id);

      Get.back();
      Get.snackbar("Success", "Gift added from ${product.shopName.isNotEmpty ? product.shopName : 'shop'}!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add gift: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Save a custom (non-marketplace) gift.
  Future<void> saveGift() async {
    if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name and Price are required");
      return;
    }

    try {
      isLoading.value = true;
      final giftId = const Uuid().v4();
      String imageUrl = "";

      if (selectedImage.value != null) {
        imageUrl = await _uploadToCloudinary(selectedImage.value!);
      }

      final price = double.tryParse(priceController.text) ?? 0.0;
      if (price <= 0) {
        Get.snackbar("Error", "Enter a valid price");
        isLoading.value = false;
        return;
      }

      final newGift = GiftModel(
        id: giftId,
        name: nameController.text.trim(),
        price: price,
        amountCollected: 0.0,
        imageUrl: imageUrl,
        category: categoryController.text.trim().isEmpty ? "General" : categoryController.text.trim(),
        isFullyFunded: false,
      );

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .set(newGift.toJson());

      Get.back();
      Get.snackbar("Success", "Gift added!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add gift: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    productCodeSearchController.clear();
    searchResult.value = null;
  }
}
