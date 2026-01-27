import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String giftId;
  final String userId;
  final String userName;      // Snapshot of name at time of gift
  final String userPhotoUrl;  // Snapshot of photo
  final double amount;
  final DateTime timestamp;
  final String? message;      // Optional "Happy Birthday!" note

  ContributionModel({
    required this.id,
    required this.giftId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.amount,
    required this.timestamp,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'giftId': giftId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'message': message,
    };
  }

  factory ContributionModel.fromMap(Map<String, dynamic> map) {
    return ContributionModel(
      id: map['id'] ?? '',
      giftId: map['giftId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      message: map['message'],
    );
  }
}