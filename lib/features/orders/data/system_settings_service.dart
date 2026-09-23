import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireshots_pos/core/constants/firebase_constants.dart';

class SystemSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _configDoc => _firestore
      .collection(FirebaseConstants.systemSettingsCollection)
      .doc(FirebaseConstants.systemConfigDocId);

  Stream<bool> get isBarOpenStream =>
      _configDoc.snapshots().map((doc) => (doc.data() ?? <String, dynamic>{})['isBarOpen'] as bool? ?? false);

  Future<bool> getIsBarOpen() async {
    final doc = await _configDoc.get();
    return (doc.data() ?? <String, dynamic>{})['isBarOpen'] as bool? ?? false;
  }

  Future<void> setBarOpen(bool isOpen) async {
    await _configDoc.set({'isBarOpen': isOpen}, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> get allSettingsStream =>
      _configDoc.snapshots().map((doc) => doc.data() ?? <String, dynamic>{});

  Future<Map<String, dynamic>> getAllSettings() async {
    final doc = await _configDoc.get();
    return doc.data() ?? <String, dynamic>{};
  }

  Future<void> updateSetting(String key, dynamic value) async {
    await _configDoc.set({key: value}, SetOptions(merge: true));
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _configDoc.set(settings, SetOptions(merge: true));
  }
}
