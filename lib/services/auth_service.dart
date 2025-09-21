import 'package:cardmaker/core/errors/firebase_error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;

  final RxBool isLoading = false.obs;

  RxBool isSkipped = false.obs;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, (d) {
      isSkipped.value = d == null;
    });
  }

  // Email & Password Sign Up
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      // Validation
      if (password != confirmPassword) {
        throw 'Passwords do not match';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters long';
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Send email verification
      await result.user?.sendEmailVerification();

      isLoading.value = false;
      return null;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Email & Password Sign In
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Check if email is verified
      if (!result.user!.emailVerified) {
        await _auth.signOut();
        throw 'Please verify your email before signing in';
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      isLoading.value = true;

      await GoogleSignIn.instance.initialize(
        serverClientId:
            "370527194012-p63ecinqsi57pdbjqvqljfnclggooh3e.apps.googleusercontent.com",
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.idToken, // ✅ kept as you originally had it
      );
      isLoading.value = false;

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }
}
