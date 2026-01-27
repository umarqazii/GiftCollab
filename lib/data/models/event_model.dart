import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String locationName;
  final String locationUrl; 
  final String imageUrl;
  
  // Naming Consistency: Use 'creatorId' everywhere
  final String creatorId; 
  final List<String> adminIds;
  final List<String> joinedUserIds; 
  final List<String> invitedEmails;
  final String invitationCode; 

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.locationName,
    required this.locationUrl,
    required this.imageUrl,
    required this.creatorId,
    required this.adminIds,
    required this.joinedUserIds,
    this.invitedEmails = const [],
    required this.invitationCode,
  });

  // --- 1. FIXED toJson (Saves ALL data) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Good practice to store ID inside the document too
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'locationName': locationName,
      'locationUrl': locationUrl,
      'imageUrl': imageUrl,
      'creatorId': creatorId, // Fixed variable name
      'adminIds': adminIds,   // Added missing field
      'joinedUserIds': joinedUserIds, // Added missing field
      'invitedEmails': invitedEmails, // Added missing field
      'invitationCode': invitationCode,
    };
  }

  // --- 2. ADDED fromMap (Required for reading from Firestore) ---
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Safely convert Timestamp to DateTime
      date: (map['date'] as Timestamp).toDate(),
      locationName: map['locationName'] ?? '',
      locationUrl: map['locationUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      creatorId: map['creatorId'] ?? '',
      // Safely convert dynamic lists to List<String>
      adminIds: List<String>.from(map['adminIds'] ?? []),
      joinedUserIds: List<String>.from(map['joinedUserIds'] ?? []),
      invitedEmails: List<String>.from(map['invitedEmails'] ?? []),
      invitationCode: map['invitationCode'] ?? '',
    );
  }
}