import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userDataProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) {
  return ref.watch(authRepositoryProvider).getUserData(uid);
});
