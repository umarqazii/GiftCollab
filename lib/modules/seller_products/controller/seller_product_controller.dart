import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../repository/seller_product_repository.dart';

class SellerProductController extends GetxController {
  final SellerProductRepository _repository = SellerProductRepository();
  final UserRepository _userRepository = UserRepository();

  // Cloudinary Setup (Directly implemented)
  final cloudinary = CloudinaryPublic('ddbllhkcb', 'giftcollab_preset', cache: false);

  // State
  var products = <ProductModel>[].obs;
  var isLoading = true.obs; // Initial list load (like My Events)
  var isUploading = false.obs; // Loader on "List Item" button

  // Form Controllers
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final inventoryController = TextEditingController();
  /// Product category for this listing (used for filtering when browsing gifts).
  var selectedProductCategory = Rxn<String>();

  // Image State
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    // Bind stream so list updates automatically when Firestore changes (like My Events)
    products.bindStream(_repository.getMyProductsStream());
    // Turn off loading once first data arrives
    ever(products, (_) {
      isLoading.value = false;
    });
  }

  // 1. Pick Image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // 2. Upload Logic (Private Helper)
  Future<String> _uploadToCloudinary(File image) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Error: $e");
      throw "Image upload failed. Please check your internet.";
    }
  }

  // 3. Main Upload Function
  Future<void> uploadProduct() async {
    // Basic Validation
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        inventoryController.text.isEmpty ||
        selectedImage.value == null) {
      Get.snackbar("Missing Info", "Please fill all fields and add an image.");
      return;
    }

    try {
      isUploading.value = true;

      // A. Current user's shop info (for product document)
      final user = await _userRepository.getCurrentUser();
      if (user == null || !user.hasShop) {
        Get.snackbar("Error", "Please create your shop first (Profile or re-enter as seller).");
        isUploading.value = false;
        return;
      }

      // B. Upload Image first
      String imageUrl = await _uploadToCloudinary(selectedImage.value!);

      // C. Create the Product Model (with shop, category, and human-readable product code)
      final newProduct = ProductModel(
        id: const Uuid().v4(),
        sellerId: FirebaseAuth.instance.currentUser!.uid,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        price: double.parse(priceController.text),
        inventory: int.parse(inventoryController.text),
        addedByCount: 0,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        productCategory: selectedProductCategory.value ?? 'Other',
        shopName: user.shopName,
        shopCategory: user.shopCategory,
        productCode: _generateProductCode(),
      );

      // D. Save to Firestore via Repository
      await _repository.addProduct(newProduct);

      // D. Cleanup
      Get.back(); // Close the bottom sheet
      Get.snackbar("Success", "Product listed successfully!");
      _clearForm();

    } catch (e) {
      Get.snackbar("Error", "Failed to list product: $e");
    } finally {
      isUploading.value = false;
    }
  }

  /// Generates a human-readable unique code for search/copy (e.g. "GC-A1B2C3D4").
  static String _generateProductCode() {
    const uuid = Uuid();
    final hex = uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    return 'GC-$hex';
  }

  void _clearForm() {
    nameController.clear();
    descController.clear();
    priceController.clear();
    inventoryController.clear();
    selectedImage.value = null;
    selectedProductCategory.value = null;
  }
}