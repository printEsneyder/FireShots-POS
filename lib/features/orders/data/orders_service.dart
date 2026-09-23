import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireshots_pos/core/constants/firebase_constants.dart';
import 'package:fireshots_pos/features/orders/data/order_model.dart';

class OrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getOrdersByStatus(String status) {
    return _firestore
        .collection(FirebaseConstants.ordersCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> getActiveOrders() {
    return _firestore
        .collection(FirebaseConstants.ordersCollection)
        .where('status', whereIn: [
          FirebaseConstants.statusPending,
          FirebaseConstants.statusAcknowledged,
          FirebaseConstants.statusDelivered,
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(FirebaseConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<bool> isTableActive(int tableNumber) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.ordersCollection)
        .where('tableNumber', isEqualTo: tableNumber)
        .where('status', whereIn: [
          FirebaseConstants.statusPending,
          FirebaseConstants.statusAcknowledged,
          FirebaseConstants.statusDelivered,
        ])
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> createOrder(OrderModel order) async {
    await _firestore
        .collection(FirebaseConstants.ordersCollection)
        .add(order.toMap());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection(FirebaseConstants.ordersCollection)
        .doc(orderId)
        .update({'status': status});
  }

  Future<void> updateOrderPayment(
      String orderId, String paymentMethod, String? servedBy) async {
    await _firestore
        .collection(FirebaseConstants.ordersCollection)
        .doc(orderId)
        .update({
      'paymentMethod': paymentMethod,
      'servedBy': servedBy,
    });
  }
}
