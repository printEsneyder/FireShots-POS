import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireshots_pos/core/constants/firebase_constants.dart';
import 'package:fireshots_pos/features/orders/data/external_debt_model.dart';

class ExternalDebtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ExternalDebt>> getDebts() {
    return _firestore
        .collection(FirebaseConstants.externalDebtsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExternalDebt.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<ExternalDebt>> getDebtsByStatus(bool isSettled) {
    return _firestore
        .collection(FirebaseConstants.externalDebtsCollection)
        .where('isSettled', isEqualTo: isSettled)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExternalDebt.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addDebt(ExternalDebt debt) async {
    await _firestore
        .collection(FirebaseConstants.externalDebtsCollection)
        .add(debt.toMap());
  }

  Future<void> markAsSettled(String debtId) async {
    await _firestore
        .collection(FirebaseConstants.externalDebtsCollection)
        .doc(debtId)
        .update({'isSettled': true});
  }
}
