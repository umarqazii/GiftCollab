import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/product_model.dart';

class SellerProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of products belonging ONLY to this seller
  Stream<List<ProductModel>> getMyProductsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('products')
        .where('sellerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).set(product.toJson());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  /// Stream of products for a given seller (for marketplace shop view).
  Stream<List<ProductModel>> getProductsBySellerStream(String sellerId) {
    return _db
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}