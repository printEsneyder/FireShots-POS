import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireshots_pos/core/constants/firebase_constants.dart';
import 'package:fireshots_pos/features/cloakroom/data/cloakroom_model.dart';

class CloakroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CloakroomItem>> getActiveItems() {
    return _firestore
        .collection(FirebaseConstants.cloakroomCollection)
        .where('isReturned', isEqualTo: false)
        .orderBy('ticketNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CloakroomItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<CloakroomItem>> getAllItems() {
    return _firestore
        .collection(FirebaseConstants.cloakroomCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CloakroomItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<String> createItem(CloakroomItem item) async {
    final docRef = await _firestore
        .collection(FirebaseConstants.cloakroomCollection)
        .add(item.toMap());
    return docRef.id;
  }

  Future<void> markAsReturned(String itemId) async {
    await _firestore
        .collection(FirebaseConstants.cloakroomCollection)
        .doc(itemId)
        .update({'isReturned': true});
  }

  Future<void> deleteAllItems() async {
    final items = await _firestore
        .collection(FirebaseConstants.cloakroomCollection)
        .get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  }
}
