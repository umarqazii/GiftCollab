import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String sellerId;
  String name;
  String description;
  double price;
  int inventory;
  int addedByCount; // Tracks urgency (how many hosts added this)
  String imageUrl;
  DateTime createdAt;
  /// Product category for filtering when browsing gifts (e.g. "Electronics").
  String productCategory;
  /// Shop name at time of listing (denormalized from user for search/filter).
  String shopName;
  /// Shop category at time of listing (denormalized from user for search/filter).
  String shopCategory;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.inventory,
    this.addedByCount = 0,
    required this.imageUrl,
    required this.createdAt,
    this.productCategory = 'Other',
    this.shopName = '',
    this.shopCategory = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sellerId': sellerId,
        'name': name,
        'description': description,
        'price': price,
        'inventory': inventory,
        'addedByCount': addedByCount,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'productCategory': productCategory,
        'shopName': shopName,
        'shopCategory': shopCategory,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      inventory: (json['inventory'] as num?)?.toInt() ?? 0,
      addedByCount: (json['addedByCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      productCategory: json['productCategory'] ?? 'Other',
      shopName: json['shopName'] ?? '',
      shopCategory: json['shopCategory'] ?? '',
    );
  }
}