import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/utils/validators.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    if (!isValidKongjuEmail(email)) {
      throw Exception('학번@${CampusConstants.emailDomain} 형식만 사용 가능합니다');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'displayName': nickname,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!credential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('이메일 인증을 완료해주세요');
    }
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
