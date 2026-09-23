import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireshots_pos/features/auth/data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userRoleProvider = FutureProvider.family<String?, String>((ref, uid) {
  return ref.watch(authServiceProvider).getUserRole(uid);
});

final userDisplayNameProvider = FutureProvider.family<String?, String>((ref, uid) {
  return ref.watch(authServiceProvider).getUserDisplayName(uid);
});
