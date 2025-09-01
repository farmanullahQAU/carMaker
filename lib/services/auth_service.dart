// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AuthService extends GetxService {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final Rx<User?> currentUser = Rx<User?>(null);

//   @override
//   void onInit() {
//     super.onInit();
//     // Listen to auth state changes and update currentUser
//     _firebaseAuth.authStateChanges().listen((User? user) {
//       currentUser.value = user;
//     });
//     // Set initial user
//     currentUser.value = _firebaseAuth.currentUser;
//   }

//   bool isUserAuthenticated() {
//     return currentUser.value != null;
//   }

//   String? getUserId() {
//     return currentUser.value?.uid;
//   }

//   void promptLogin() {
//     Get.snackbar(
//       'Login Required',
//       'Please log in to perform this action',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.orange.shade100,
//       colorText: Colors.orange.shade900,
//       duration: const Duration(seconds: 3),
//       mainButton: TextButton(
//         onPressed: () {
//           // Get.toNamed(Routes.login);
//         },
//         child: Text(
//           'Log In',
//           style: Get.textTheme.bodyMedium?.copyWith(
//             color: Colors.blue.shade700,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // Optional: Method to sign out (if needed elsewhere in the app)
//   Future<void> signOut() async {
//     try {
//       await _firebaseAuth.signOut();
//       currentUser.value = null;
//       // Get.offAllNamed(Routes.login);
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to sign out: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade900,
//       );
//     }
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
  }

  // Email & Password Sign Up
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

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
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return _handleFirebaseError(e);
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Email & Password Sign In
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Check if email is verified
      if (!result.user!.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email before signing in';
      }

      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return _handleFirebaseError(e);
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await GoogleSignIn.instance.initialize(
        serverClientId:
            "370527194012-p63ecinqsi57pdbjqvqljfnclggooh3e.apps.googleusercontent.com",
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      isLoading.value = false;
      return null;
    } catch (e) {
      print("error");
      print(e);
      isLoading.value = false;
      return e.toString();
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
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return _handleFirebaseError(e);
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Error handling
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address format';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
