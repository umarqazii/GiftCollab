import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; // run 'flutter pub add uuid' if missing, or use manual random string
import '../../../data/models/event_model.dart';

class CreateEventController extends GetxController {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationNameController = TextEditingController();
  final locationUrlController = TextEditingController();
  
  // Observables
  var selectedDate = DateTime.now().obs;
  var selectedImage = Rxn<File>(); // Nullable File
  var isLoading = false.obs;

  final cloudinary = CloudinaryPublic('ddbllhkcb', 'giftcollab_preset', cache: false);
  
  // Generated Link Preview
  var invitationLink = "giftcollab.app/invite/${const Uuid().v4().substring(0, 8)}".obs;

  @override
  void onInit() {
    super.onInit();
    // Regenerate code if needed, or keep static
  }

  // 1. Pick Image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<String> _uploadToCloudinary(File image) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Error: $e");
      throw "Image upload failed. Please check your connection.";
    }
  }

  // 2. Pick Date
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  // 3. Create Event
  Future<void> createEvent() async {
    if (titleController.text.isEmpty || locationNameController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all required fields");
      return;
    }

    try {
      isLoading.value = true;
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String eventId = const Uuid().v4();

      String imageUrl = "";

      if (selectedImage.value != null) {
        imageUrl = await _uploadToCloudinary(selectedImage.value!);
      }

      final newEvent = EventModel(
        id: eventId,
        title: titleController.text,
        description: descController.text,
        date: selectedDate.value,
        locationName: locationNameController.text,
        locationUrl: locationUrlController.text,
        imageUrl: imageUrl,
        creatorId: uid,
        invitationCode: invitationLink.value.split('/').last,
        adminIds: [uid],
        joinedUserIds: [],
        invitedEmails: [],
      );

      // 3. Save to Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .set(newEvent.toJson());

      Get.back();
      Get.snackbar("Success", "Event Created Successfully!");

    } catch (e) {
      Get.snackbar("Error", "Failed to create event: $e");
      
    } finally {
      isLoading.value = false;
    }
  }
}