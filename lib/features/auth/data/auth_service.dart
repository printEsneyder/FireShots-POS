import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireshots_pos/core/constants/firebase_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    return doc.data()?['role'] as String?;
  }

  Future<String?> getUserDisplayName(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    return doc.data()?['displayName'] as String?;
  }
}
