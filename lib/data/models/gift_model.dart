import 'package:cloud_firestore/cloud_firestore.dart';

class GiftModel {
  final String id;
  final String name;
  final double price;       // Target amount (e.g., $500)
  final double amountCollected; // Current funding (e.g., $150)
  final String imageUrl;    // Optional image of the item
  final String category;    // e.g., "Home", "Honeymoon", "Electronics"
  final bool isFullyFunded;

  /// When gift is from marketplace: product document id.
  final String productId;
  /// Human-readable product code (e.g. GC-A1B2C3D4) for reference/search.
  final String productCode;
  /// Seller uid when gift is from marketplace.
  final String sellerId;
  /// Shop name when gift is from marketplace.
  final String shopName;
  /// Shop category when gift is from marketplace.
  final String shopCategory;

  GiftModel({
    required this.id,
    required this.name,
    required this.price,
    this.amountCollected = 0.0,
    required this.imageUrl,
    this.category = "General",
    this.isFullyFunded = false,
    this.productId = '',
    this.productCode = '',
    this.sellerId = '',
    this.shopName = '',
    this.shopCategory = '',
  });

  bool get isFromMarketplace => productId.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'amountCollected': amountCollected,
      'imageUrl': imageUrl,
      'category': category,
      'isFullyFunded': isFullyFunded,
      'productId': productId,
      'productCode': productCode,
      'sellerId': sellerId,
      'shopName': shopName,
      'shopCategory': shopCategory,
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
      productId: map['productId'] ?? '',
      productCode: map['productCode'] ?? '',
      sellerId: map['sellerId'] ?? '',
      shopName: map['shopName'] ?? '',
      shopCategory: map['shopCategory'] ?? '',
    );
  }
}