import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes and update currentUser
    _firebaseAuth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
    // Set initial user
    currentUser.value = _firebaseAuth.currentUser;
  }

  bool isUserAuthenticated() {
    return currentUser.value != null;
  }

  String? getUserId() {
    return currentUser.value?.uid;
  }

  void promptLogin() {
    Get.snackbar(
      'Login Required',
      'Please log in to perform this action',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          // Get.toNamed(Routes.login);
        },
        child: Text(
          'Log In',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Optional: Method to sign out (if needed elsewhere in the app)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      currentUser.value = null;
      // Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}
