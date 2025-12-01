import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 Auth state stream (used in main.dart to detect login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔥 Get current user
  User? get currentUser => _auth.currentUser;

  // ✅ Create account
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Send verification email
      await sendEmailVerification();

      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return e.message; // return readable error message
    }
  }

  // ✅ Login
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ✅ Send verification email
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ✅ Check if email is verified (refresh user)
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return user.emailVerified;
  }

  // ✅ Send password reset email
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ✅ Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
