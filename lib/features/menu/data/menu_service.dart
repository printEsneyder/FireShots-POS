import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireshots_pos/core/constants/firebase_constants.dart';
import 'package:fireshots_pos/features/menu/data/product_model.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _firestore
        .collection(FirebaseConstants.productsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Product>> getAvailableProducts() {
    return _firestore
        .collection(FirebaseConstants.productsCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addProduct(Product product) async {
    await _firestore
        .collection(FirebaseConstants.productsCollection)
        .add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection(FirebaseConstants.productsCollection)
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore
        .collection(FirebaseConstants.productsCollection)
        .doc(productId)
        .delete();
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _firestore
        .collection(FirebaseConstants.productsCollection)
        .doc(productId)
        .update({'stock': newStock});
  }
}
