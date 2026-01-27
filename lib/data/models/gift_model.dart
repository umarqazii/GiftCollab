import 'package:cloud_firestore/cloud_firestore.dart';

class GiftModel {
  final String id;
  final String name;
  final double price;       // Target amount (e.g., $500)
  final double amountCollected; // Current funding (e.g., $150)
  final String imageUrl;    // Optional image of the item
  final String category;    // e.g., "Home", "Honeymoon", "Electronics"
  final bool isFullyFunded;

  GiftModel({
    required this.id,
    required this.name,
    required this.price,
    this.amountCollected = 0.0,
    required this.imageUrl,
    this.category = "General",
    this.isFullyFunded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'amountCollected': amountCollected,
      'imageUrl': imageUrl,
      'category': category,
      'isFullyFunded': isFullyFunded,
    };
  }

  factory GiftModel.fromMap(Map<String, dynamic> map) {
    return GiftModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      amountCollected: (map['amountCollected'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'General',
      isFullyFunded: map['isFullyFunded'] ?? false,
    );
  }
}