import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _storage.write(key: 'user_email', value: email);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _storage.write(key: 'user_email', value: email);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'user_email');
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> getSavedEmail() async {
    return await _storage.read(key: 'user_email');
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email registered nahi hai. Pehle sign up karein.';
      case 'wrong-password':
        return 'Galat password. Dobara try karein.';
      case 'email-already-in-use':
        return 'Yeh email pehle se registered hai. Sign in karein.';
      case 'weak-password':
        return 'Password kam se kam 6 characters ka hona chahiye.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Koi error aaya: ${e.message}';
    }
  }
}
