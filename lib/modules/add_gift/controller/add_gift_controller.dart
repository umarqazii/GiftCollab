import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/gift_model.dart';

class AddGiftController extends GetxController {
  final String eventId; // Passed in arguments

  AddGiftController(this.eventId); // Constructor injection

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();

  var selectedImage = Rxn<File>();
  var isLoading = false.obs;

  // Cloudinary Setup (Reuse your keys)
  final cloudinary = CloudinaryPublic('YOUR_CLOUD_NAME', 'YOUR_UPLOAD_PRESET', cache: false);

  // Pick Image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage.value = File(image.path);
  }

  // Upload Logic
  Future<String> _uploadToCloudinary(File image) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      throw "Image upload failed.";
    }
  }

  // Save Gift
  Future<void> saveGift() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar("Error", "Name and Price are required");
      return;
    }

    try {
      isLoading.value = true;
      String giftId = const Uuid().v4();
      String imageUrl = "";

      // 1. Upload Image
      if (selectedImage.value != null) {
        imageUrl = await _uploadToCloudinary(selectedImage.value!);
      }

      // 2. Parse Price
      double price = double.parse(priceController.text);

      // 3. Create Model
      final newGift = GiftModel(
        id: giftId,
        name: nameController.text,
        price: price,
        imageUrl: imageUrl,
        category: categoryController.text.isEmpty ? "General" : categoryController.text,
      );

      // 4. Save to Sub-Collection
      // Path: events -> {eventId} -> gifts -> {giftId}
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .set(newGift.toJson());

      Get.back(); // Close screen
      Get.snackbar("Success", "Gift Added!");

    } catch (e) {
      Get.snackbar("Error", "Failed to add gift: $e");
    } finally {
      isLoading.value = false;
    }
  }
}