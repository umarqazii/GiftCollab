import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/data/repositories/user_repository.dart';
import 'package:gift_collab/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';

class CreateShopController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final cloudinary = CloudinaryPublic('ddbllhkcb', 'giftcollab_preset', cache: false);

  final shopNameController = TextEditingController();
  final shopCategoryController = TextEditingController();
  var selectedImage = Rxn<File>();
  var isSaving = false.obs;
  var selectedCategory = Rxn<String>();

  @override
  void onClose() {
    shopNameController.dispose();
    shopCategoryController.dispose();
    super.onClose();
  }


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) selectedImage.value = File(xFile.path);
  }

  Future<String> _uploadImage(File file) async {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
    );
    return response.secureUrl;
  }

  Future<void> createShop() async {
    final name = shopNameController.text.trim();
    final category = selectedCategory.value ?? shopCategoryController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Missing info', 'Please enter your shop name.');
      return;
    }
    if (selectedImage.value == null) {
      Get.snackbar('Missing info', 'Please add a shop display image.');
      return;
    }

    try {
      isSaving.value = true;
      final imageUrl = await _uploadImage(selectedImage.value!);
      await _userRepository.updateShopInfo(
        shopName: name,
        shopDisplayPicUrl: imageUrl,
        shopCategory: category.isEmpty ? 'Other' : category,
      );
      Get.snackbar('Success', 'Shop created!');
      Get.offAllNamed(Routes().getSellerHomeScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to create shop: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
